import std/unittest

import javascriptcore

proc pointCtor(ctx: JSContextRef; constructor: JSObjectRef;
               argumentCount: csize_t; arguments: ptr JSValueRef;
               exception: ptr JSValueRef): JSObjectRef {.cdecl.} =
  JSObjectMake(ctx, nil, nil)

test "make array date error regexp":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    var items = [JSValueMakeNumber(ctx, 1.0), JSValueMakeNumber(ctx, 2.0)]
    let arr = JSObjectMakeArray(ctx, 2, addr items[0], addr ex)
    check ex == nil
    check JSValueIsArray(ctx, arr)
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx,
      JSObjectGetPropertyAtIndex(ctx, arr, 1, addr ex2), addr ex2) == 2.0
    JSObjectSetPropertyAtIndex(ctx, arr, 0, JSValueMakeNumber(ctx, 9.0),
                               addr ex)
    check ex == nil
    check JSValueToNumber(ctx,
      JSObjectGetPropertyAtIndex(ctx, arr, 0, addr ex2), addr ex2) == 9.0
    let date = JSObjectMakeDate(ctx, 0, nil, addr ex)
    check ex == nil
    check JSValueIsDate(ctx, date)
    let msg = newJSString("oops")
    var msgArg = [JSValueMakeString(ctx, msg)]
    JSStringRelease(msg)
    let err = JSObjectMakeError(ctx, 1, addr msgArg[0], addr ex)
    check ex == nil
    check JSValueIsObject(ctx, err)
    let pat = newJSString("^a+$")
    var reArgs = [JSValueMakeString(ctx, pat)]
    JSStringRelease(pat)
    let re = JSObjectMakeRegExp(ctx, 1, addr reArgs[0], addr ex)
    check ex == nil
    check JSValueIsObject(ctx, re)

test "error is instanceof Error":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let err = evalScript(ctx, "new Error('x')", exception = ex)
    check ex == nil
    let global = JSContextGetGlobalObject(ctx)
    let name = newJSString("Error")
    defer: JSStringRelease(name)
    let ctor = JSObjectGetProperty(ctx, global, name, addr ex)
    check ex == nil
    check JSValueIsInstanceOfConstructor(ctx, err, ctor, addr ex)
    check ex == nil

test "make function from source":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let name = newJSString("triple")
    defer: JSStringRelease(name)
    var params = [newJSString("x")]
    defer: JSStringRelease(params[0])
    let body = newJSString("return x * 3;")
    defer: JSStringRelease(body)
    let fn = JSObjectMakeFunction(ctx, name, 1, addr params[0], body, nil, 1,
                                  addr ex)
    check ex == nil
    check fn != nil
    var args = [JSValueMakeNumber(ctx, 7.0)]
    let res = JSObjectCallAsFunction(ctx, fn, nil, 1, addr args[0], addr ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, res, addr ex2) == 21.0

test "make constructor and instantiate":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let ctor = JSObjectMakeConstructor(ctx, nil, pointCtor)
    check ctor != nil
    check JSObjectIsConstructor(ctx, ctor)
    var args = [JSValueMakeNumber(ctx, 1.0)]
    let inst = JSObjectCallAsConstructor(ctx, ctor, 1, addr args[0], addr ex)
    check ex == nil
    check inst != nil
    check JSValueIsObject(ctx, inst)
    check JSValueIsInstanceOfConstructor(ctx, inst, ctor, addr ex)
    check ex == nil

test "prototype get and set":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let obj = evalScript(ctx, "({})", exception = ex)
    check ex == nil
    let proto = evalScript(ctx, "({tag: 'p'})", exception = ex)
    check ex == nil
    JSObjectSetPrototype(ctx, obj, proto)
    check JSObjectGetPrototype(ctx, obj) == proto
    let g = JSContextGetGlobalObject(ctx)
    let k = newJSString("obj")
    defer: JSStringRelease(k)
    JSObjectSetProperty(ctx, g, k, obj, kJSPropertyAttributeNone, addr ex)
    check ex == nil
    let tag = evalScript(ctx, "obj.tag", exception = ex)
    check ex == nil
    check JSValueIsString(ctx, tag)
    let tagStr = JSValueToStringCopy(ctx, tag, addr ex)
    check ex == nil
    defer: JSStringRelease(tagStr)
    check $tagStr == "p"

test "context name round trip":
  withGlobalContext(ctx):
    let n = newJSString("main")
    defer: JSStringRelease(n)
    JSGlobalContextSetName(ctx, n)
    let copy = JSGlobalContextCopyName(ctx)
    check copy != nil
    defer: JSStringRelease(copy)
    check $copy == "main"

test "two contexts share objects in one group":
  let group = JSContextGroupCreate()
  defer: JSContextGroupRelease(group)
  let ctx1 = JSGlobalContextCreateInGroup(group, nil)
  defer: JSGlobalContextRelease(ctx1)
  let ctx2 = JSGlobalContextCreateInGroup(group, nil)
  defer: JSGlobalContextRelease(ctx2)
  check JSContextGetGroup(ctx1) == group
  check JSContextGetGroup(ctx2) == group
  check JSContextGetGlobalContext(ctx1) == ctx1
  var ex: JSValueRef = nil
  let obj = evalScript(ctx1, "({shared: 123})", exception = ex)
  check ex == nil
  let g2 = JSContextGetGlobalObject(ctx2)
  let k = newJSString("o")
  defer: JSStringRelease(k)
  JSObjectSetProperty(ctx2, g2, k, obj, kJSPropertyAttributeNone, addr ex)
  check ex == nil
  var ex2: JSValueRef = nil
  let v = evalScript(ctx2, "o.shared", exception = ex2)
  check ex2 == nil
  var ex3: JSValueRef = nil
  check JSValueToNumber(ctx2, v, addr ex3) == 123.0
