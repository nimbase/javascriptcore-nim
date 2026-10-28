import std/unittest

import javascriptcore

test "utf8 string round trip":
  let s = newJSString("hello")
  defer: JSStringRelease(s)
  check $s == "hello"

test "unicode round trip":
  let s = newJSString("h\xC3\xA9llo \xF0\x9F\x8C\x8D") # hello + umlaut + globe
  defer: JSStringRelease(s)
  check $s == "h\xC3\xA9llo \xF0\x9F\x8C\x8D"

test "empty string":
  let s = newJSString("")
  defer: JSStringRelease(s)
  check $s == ""
  check JSStringGetLength(s) == 0

test "length counts utf16 units":
  let s = newJSString("abc")
  defer: JSStringRelease(s)
  check JSStringGetLength(s) == 3
  let emoji = newJSString("\xF0\x9F\x8C\x8D") # U+1F30D, surrogate pair
  defer: JSStringRelease(emoji)
  check JSStringGetLength(emoji) == 2

test "equality":
  let a = newJSString("same")
  defer: JSStringRelease(a)
  let b = newJSString("same")
  defer: JSStringRelease(b)
  let c = newJSString("different")
  defer: JSStringRelease(c)
  check JSStringIsEqual(a, b)
  check not JSStringIsEqual(a, c)
  check JSStringIsEqualToUTF8CString(a, "same")
  check not JSStringIsEqualToUTF8CString(a, "other")

test "characters constructor":
  var chars = [uint16('h'), uint16('i')]
  let s = JSStringCreateWithCharacters(addr chars[0], 2)
  defer: JSStringRelease(s)
  check $s == "hi"

test "retain gives the same string":
  let s = newJSString("kept")
  let r = JSStringRetain(s)
  JSStringRelease(s) # original released; retained copy must survive
  check $r == "kept"
  JSStringRelease(r)
