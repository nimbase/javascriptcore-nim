import std/unittest

import javascriptcore

test "evaluate arithmetic":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let res = evalScript(ctx, "1 + 2", exception = ex)
    check ex == nil
    check res != nil
    check JSValueGetType(ctx, res) == kJSTypeNumber
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, res, addr ex2) == 3.0
    check ex2 == nil

test "values have the right types":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    check JSValueIsUndefined(ctx, evalScript(ctx, "undefined", exception = ex))
    check JSValueIsNull(ctx, evalScript(ctx, "null", exception = ex))
    check JSValueIsBoolean(ctx, evalScript(ctx, "true", exception = ex))
    check JSValueIsString(ctx, evalScript(ctx, "'hi'", exception = ex))
    check JSValueIsObject(ctx, evalScript(ctx, "({})", exception = ex))
    check JSValueIsArray(ctx, evalScript(ctx, "[1, 2]", exception = ex))
    check ex == nil

test "strict equality and instanceof":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let a = evalScript(ctx, "[1, 2, 3]", exception = ex)
    let b = evalScript(ctx, "[1, 2, 3]", exception = ex)
    check ex == nil
    check not JSValueIsStrictEqual(ctx, a, b) # distinct identities
    check JSValueIsEqual(ctx, a, a, addr ex)
    check ex == nil
    let isArr = evalScript(ctx, "Array", exception = ex)
    check JSValueIsInstanceOfConstructor(ctx, a, isArr, addr ex)
    check ex == nil

test "json round trip":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let v = evalScript(ctx, """({"a": 1})""", exception = ex)
    check ex == nil
    let s = JSValueCreateJSONString(ctx, v, 0, addr ex)
    check ex == nil
    check $s == """{"a":1}"""
    JSStringRelease(s)
    let js = newJSString("[1, 2, 3]")
    let parsed = JSValueMakeFromJSONString(ctx, js)
    JSStringRelease(js)
    check parsed != nil
    check JSValueIsArray(ctx, parsed)

test "check syntax without throwing":
  withGlobalContext(ctx):
    let good = newJSString("function f() { return 1; }")
    defer: JSStringRelease(good)
    let bad = newJSString("function (")
    defer: JSStringRelease(bad)
    var ex: JSValueRef = nil
    check JSCheckScriptSyntax(ctx, good, nil, 1, addr ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check not JSCheckScriptSyntax(ctx, bad, nil, 1, addr ex2)
    check ex2 != nil
