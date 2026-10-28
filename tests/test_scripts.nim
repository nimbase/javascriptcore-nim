import std/unittest

import javascriptcore

proc numVal(ctx: JSContextRef; script: string): float64 =
  var ex: JSValueRef = nil
  let v = evalScript(ctx, script, exception = ex)
  assert ex == nil
  assert v != nil
  var ex2: JSValueRef = nil
  result = JSValueToNumber(ctx, v, addr ex2)
  assert ex2 == nil

proc strVal(ctx: JSContextRef; script: string): string =
  var ex: JSValueRef = nil
  let v = evalScript(ctx, script, exception = ex)
  assert ex == nil
  assert v != nil
  var ex2: JSValueRef = nil
  let s = JSValueToStringCopy(ctx, v, addr ex2)
  assert ex2 == nil
  result = $s
  JSStringRelease(s)

test "fibonacci recursion":
  withGlobalContext(ctx):
    check numVal(ctx, """
      function fib(n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }
      fib(10)
    """) == 55.0

test "closure counter":
  withGlobalContext(ctx):
    check numVal(ctx, """
      function make() { let n = 0; return () => ++n; }
      const c = make();
      c(); c(); c();
    """) == 3.0

test "array filter map reduce":
  withGlobalContext(ctx):
    check numVal(ctx,
      "[1, 2, 3, 4].filter(x => x % 2 === 0).map(x => x * 10)" &
      ".reduce((a, b) => a + b, 0)") == 60.0

test "loop sum":
  withGlobalContext(ctx):
    check numVal(ctx,
      "let s = 0; for (let i = 1; i <= 100; i++) s += i; s") == 5050.0

test "es6 class":
  withGlobalContext(ctx):
    check numVal(ctx, """
      class Rect {
        constructor(w, h) { this.w = w; this.h = h; }
        area() { return this.w * this.h; }
      }
      new Rect(3, 4).area()
    """) == 12.0

test "template literals and string methods":
  withGlobalContext(ctx):
    check strVal(ctx, """
      const name = "world";
      `hello, ${name}!`.toUpperCase()
    """) == "HELLO, WORLD!"

test "math builtins":
  withGlobalContext(ctx):
    check numVal(ctx, "Math.floor(Math.PI * 100)") == 314.0
    check numVal(ctx, "Math.max(3, 7, 5)") == 7.0
    check strVal(ctx, "(255).toString(16)") == "ff"

test "date and regexp":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let d = evalScript(ctx, "new Date(2020, 0, 2)", exception = ex)
    check ex == nil
    check JSValueIsDate(ctx, d)
    check numVal(ctx, "new Date(2020, 0, 1).getFullYear()") == 2020.0
    let ok = evalScript(ctx, "/^h.llo$/.test('hello')", exception = ex)
    check ex == nil
    check JSValueToBoolean(ctx, ok)

test "try catch inside js":
  withGlobalContext(ctx):
    check strVal(ctx, """
      function f() {
        try { throw new Error("inner"); }
        catch (e) { return e.message; }
      }
      f()
    """) == "inner"

test "globals persist across evals":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    discard evalScript(ctx, "var counter = 41;", exception = ex)
    check ex == nil
    check numVal(ctx, "counter += 1; counter") == 42.0
    check strVal(ctx, "typeof counter") == "number"
    check strVal(ctx, "typeof noSuchThing") == "undefined"

test "json stringify in js":
  withGlobalContext(ctx):
    check strVal(ctx, "JSON.stringify({a: [1, 2]})") == """{"a":[1,2]}"""

test "destructuring spread defaults":
  withGlobalContext(ctx):
    check numVal(ctx, "const [a, ...rest] = [1, 2, 3]; rest.length") == 2.0
    check numVal(ctx, "const add = (a, b = 10) => a + b; add(5)") == 15.0
    check strVal(ctx, "const {x, y = 7} = {x: 1}; x + ':' + y") == "1:7"
