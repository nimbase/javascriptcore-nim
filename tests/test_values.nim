import std/unittest
import std/math

import javascriptcore

test "make primitives and check types":
  withGlobalContext(ctx):
    check JSValueGetType(ctx, JSValueMakeUndefined(ctx)) == kJSTypeUndefined
    check JSValueGetType(ctx, JSValueMakeNull(ctx)) == kJSTypeNull
    check JSValueGetType(ctx, JSValueMakeBoolean(ctx, true)) == kJSTypeBoolean
    check JSValueGetType(ctx, JSValueMakeNumber(ctx, 1.5)) == kJSTypeNumber
    let s = newJSString("v")
    defer: JSStringRelease(s)
    check JSValueGetType(ctx, JSValueMakeString(ctx, s)) == kJSTypeString
    check JSValueIsBoolean(ctx, JSValueMakeBoolean(ctx, false))
    let t = JSValueMakeBoolean(ctx, true)
    check JSValueToBoolean(ctx, t)
    check not JSValueToBoolean(ctx, JSValueMakeBoolean(ctx, false))

test "truthiness conversions":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    check not JSValueToBoolean(ctx, evalScript(ctx, "0", exception = ex))
    check not JSValueToBoolean(ctx, evalScript(ctx, "''", exception = ex))
    check not JSValueToBoolean(ctx, evalScript(ctx, "undefined",
      exception = ex))
    check JSValueToBoolean(ctx, evalScript(ctx, "'x'", exception = ex))
    check JSValueToBoolean(ctx, evalScript(ctx, "[]", exception = ex))
    check ex == nil

test "toString of primitives":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    for (script, expected) in [("42", "42"), ("true", "true"),
        ("undefined", "undefined"), ("null", "null"),
        ("'a' + 'b'", "ab")]:
      let v = evalScript(ctx, script, exception = ex)
      check ex == nil
      let s = JSValueToStringCopy(ctx, v, addr ex)
      check ex == nil
      check $s == expected
      JSStringRelease(s)

test "nan and infinity":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    check JSValueToNumber(ctx, evalScript(ctx, "0/0", exception = ex),
      addr ex).isNaN
    check ex == nil
    let inf = JSValueToNumber(ctx, evalScript(ctx, "1/0", exception = ex),
      addr ex)
    check ex == nil
    check inf.classify == fcInf

test "toObject wraps primitives":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let wrapped = JSValueToObject(ctx, evalScript(ctx, "42", exception = ex),
      addr ex)
    check ex == nil
    check JSValueIsObject(ctx, wrapped)
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, wrapped, addr ex2) == 42.0

test "symbol creation":
  withGlobalContext(ctx):
    let desc = newJSString("mysym")
    defer: JSStringRelease(desc)
    let s = JSValueMakeSymbol(ctx, desc)
    check s != nil
    check JSValueGetType(ctx, s) == kJSTypeSymbol
    check JSValueIsSymbol(ctx, s)
    check not JSValueIsSymbol(ctx, JSValueMakeNumber(ctx, 1.0))

test "deferred promise":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    var resolve, reject: JSObjectRef = nil
    let p = JSObjectMakeDeferredPromise(ctx, addr resolve, addr reject,
                                        addr ex)
    check ex == nil
    check p != nil
    check JSValueIsObject(ctx, p)
    check resolve != nil
    check reject != nil
    check JSObjectIsFunction(ctx, resolve)
    check JSObjectIsFunction(ctx, reject)

test "key based property access":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let obj = evalScript(ctx, "({})", exception = ex)
    check ex == nil
    let key = evalScript(ctx, "'dyn' + 'Key'", exception = ex)
    check ex == nil
    check not JSObjectHasPropertyForKey(ctx, obj, key, addr ex)
    check ex == nil
    JSObjectSetPropertyForKey(ctx, obj, key, JSValueMakeNumber(ctx, 7.0),
                              kJSPropertyAttributeNone, addr ex)
    check ex == nil
    check JSObjectHasPropertyForKey(ctx, obj, key, addr ex)
    check ex == nil
    let got = JSObjectGetPropertyForKey(ctx, obj, key, addr ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, got, addr ex2) == 7.0
    check JSObjectDeletePropertyForKey(ctx, obj, key, addr ex)
    check ex == nil
    check not JSObjectHasPropertyForKey(ctx, obj, key, addr ex)
