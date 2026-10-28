import std/unittest
import std/strutils

import javascriptcore

test "thrown error is captured":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let res = evalScript(ctx, "throw new Error('boom')", exception = ex)
    check res == nil
    check ex != nil
    var ex2: JSValueRef = nil
    let msg = JSValueToStringCopy(ctx, ex, addr ex2)
    check ex2 == nil
    check ($msg).contains("boom")
    JSStringRelease(msg)

test "reference error is captured":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let res = evalScript(ctx, "noSuchVariable + 1", exception = ex)
    check res == nil
    check ex != nil
    check JSValueIsObject(ctx, ex)

test "no exception leaves the out-param nil":
  withGlobalContext(ctx):
    var ex: JSValueRef = JSValueMakeUndefined(ctx) # poison; must be reset
    ex = nil
    let res = evalScript(ctx, "40 + 2", exception = ex)
    check ex == nil
    var ex2: JSValueRef = nil
    check JSValueToNumber(ctx, res, addr ex2) == 42.0

test "garbage collect runs clean":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    discard evalScript(ctx, "let tmp = {x: 1}; tmp.x", exception = ex)
    check ex == nil
    JSGarbageCollect(ctx)
