import std/unittest

import javascriptcore

proc addFn(ctx: JSContextRef; function, thisObject: JSObjectRef;
           argumentCount: csize_t; arguments: ptr JSValueRef;
           exception: ptr JSValueRef): JSValueRef {.cdecl.} =
  var sum = 0.0
  if argumentCount > 0 and arguments != nil:
    let args = cast[ptr UncheckedArray[JSValueRef]](arguments)
    for i in 0 ..< int(argumentCount):
      var ex: JSValueRef = nil
      sum += JSValueToNumber(ctx, args[i], addr ex)
      if ex != nil:
        if exception != nil:
          exception[] = ex
        return nil
  JSValueMakeNumber(ctx, sum)

test "native callback callable from js":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let name = newJSString("add")
    defer: JSStringRelease(name)
    let fn = JSObjectMakeFunctionWithCallback(ctx, name, addFn)
    check fn != nil
    check JSObjectIsFunction(ctx, fn)
    check not JSObjectIsConstructor(ctx, fn)
    let global = JSContextGetGlobalObject(ctx)
    let prop = newJSString("add")
    defer: JSStringRelease(prop)
    JSObjectSetProperty(ctx, global, prop, fn, kJSPropertyAttributeNone,
                        addr ex)
    check ex == nil
    let res = evalScript(ctx, "add(20, 22)", exception = ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, res, addr ex2) == 42.0

test "call function directly":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let fn = JSObjectMakeFunctionWithCallback(ctx, nil, addFn)
    check fn != nil
    var numArgs = [JSValueMakeNumber(ctx, 3.0), JSValueMakeNumber(ctx, 4.0)]
    let res = JSObjectCallAsFunction(ctx, fn, nil, 2, addr numArgs[0],
                                     addr ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, res, addr ex2) == 7.0

test "property set get delete":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let global = JSContextGetGlobalObject(ctx)
    let key = newJSString("answer")
    defer: JSStringRelease(key)
    check not JSObjectHasProperty(ctx, global, key)
    JSObjectSetProperty(ctx, global, key, JSValueMakeNumber(ctx, 42.0),
                        kJSPropertyAttributeNone, addr ex)
    check ex == nil
    check JSObjectHasProperty(ctx, global, key)
    let got = JSObjectGetProperty(ctx, global, key, addr ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, got, addr ex2) == 42.0
    check JSObjectDeleteProperty(ctx, global, key, addr ex)
    check ex == nil
    check not JSObjectHasProperty(ctx, global, key)

test "property names listing":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let obj = JSObjectMake(ctx, nil, nil)
    check obj != nil
    JSValueProtect(ctx, obj)
    defer: JSValueUnprotect(ctx, obj)
    let key = newJSString("listed")
    defer: JSStringRelease(key)
    JSObjectSetProperty(ctx, obj, key, JSValueMakeNumber(ctx, 1.0),
                        kJSPropertyAttributeNone, addr ex)
    check ex == nil
    let names = JSObjectCopyPropertyNames(ctx, obj)
    check names != nil
    defer: JSPropertyNameArrayRelease(names)
    check JSPropertyNameArrayGetCount(names) == 1
    let first = JSPropertyNameArrayGetNameAtIndex(names, 0)
    check $first == "listed" # borrowed; array release covers it

test "custom class with private data":
  withGlobalContext(ctx):
    var def = kJSClassDefinitionEmpty
    def.version = 0
    def.className = "Sentinel"
    let cls = JSClassCreate(addr def)
    check cls != nil
    defer: JSClassRelease(cls)
    let obj = JSObjectMake(ctx, cls, cast[pointer](0xBEEF))
    check obj != nil
    JSValueProtect(ctx, obj)
    defer: JSValueUnprotect(ctx, obj)
    check JSObjectGetPrivate(obj) == cast[pointer](0xBEEF)
    check JSObjectSetPrivate(obj, nil)
    check JSObjectGetPrivate(obj) == nil
    var ex: JSValueRef = nil
    check JSValueIsObjectOfClass(ctx, obj, cls)
