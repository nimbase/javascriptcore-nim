<p align="center">
  Nim bindings to JavaScriptCore<br>
</p>

<p align="center">
  <code>nimble install javascriptcore</code>
</p>

<p align="center">
  <a href="https://nimbase.github.io/javascriptcore-nim/">API reference</a><br>
  <img src="https://github.com/nimbase/javascriptcore-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/nimbase/javascriptcore-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

> [!NOTE]
> macOS is the configuration this package is developed and tested against
> (JavaScriptCore ships with the OS). Linux via WebKitGTK is planned; the
> link block already carries a `jscPkg` override hook for it.

## Features
- Complete low-level JavaScriptCore C API: contexts and groups, strings,
  values, objects, classes and callbacks, typed arrays and array buffers,
  promises, JSON, symbols, plus the macOS `JSStringRefCF` glue
- C names kept verbatim with `importc`, so Apple's C documentation applies
  one to one
- Opaque structs stay ABI identical, so callbacks (function, constructor,
  property, class callbacks, byte deallocators) are plain Nim `{.cdecl.}`
  procs with no casts
- Thin helpers on top: `newJSString`, `$`, `evalScript`, `withGlobalContext`
- Links the system JavaScriptCore framework; nothing is vendored
- Tested against the real engine: evaluation, realistic scripts, native
  callbacks, custom classes, typed arrays, exceptions, and JSON roundtrips

## Roadmap
- [x] Complete low-level C API (`JSBase`, `JSContextRef`, `JSStringRef`,
  `JSValueRef`, `JSObjectRef`, `JSTypedArray`, macOS `JSStringRefCF`)
- [x] macOS framework linking, tested against the system JavaScriptCore
- [x] Custom static `libjavascriptcore` linking (`jscStaticLib`,
  `jscIncludeDir`)
- [x] Thin helpers (`newJSString`, `$`, `evalScript`, `withGlobalContext`)
- [x] Test suite (51 tests: eval, scripts, callbacks, classes, typed arrays,
  exceptions, JSON)
- [ ] Linux support via WebKitGTK (`jscPkg` hook present, unverified)
- [ ] High-level idiomatic layer (GC-managed values, exceptions as Nim errors)
- [ ] Windows support (not planned)

## Examples
Evaluate a script and read back a number:
```nim
import javascriptcore

withGlobalContext(ctx):
  var ex: JSValueRef = nil
  let res = evalScript(ctx, "1 + 2", exception = ex)
  assert ex == nil
  var numEx: JSValueRef = nil
  echo JSValueToNumber(ctx, res, addr numEx) # 3.0
```

Handle errors and convert values to strings:
```nim
import javascriptcore

withGlobalContext(ctx):
  var ex: JSValueRef = nil
  let res = evalScript(ctx, "JSON.stringify({a: [1, 2]})", exception = ex)
  if ex != nil:
    var dumpEx: JSValueRef = nil
    let msg = JSValueToStringCopy(ctx, ex, addr dumpEx)
    echo "failed: ", $msg
    JSStringRelease(msg)
  else:
    var convEx: JSValueRef = nil
    let s = JSValueToStringCopy(ctx, res, addr convEx)
    echo $s # {"a":[1,2]}
    JSStringRelease(s)
```

Expose a native function and call it from JavaScript:
```nim
import javascriptcore

proc addFn(ctx: JSContextRef; function, thisObject: JSObjectRef;
           argumentCount: csize_t; arguments: ptr JSValueRef;
           exception: ptr JSValueRef): JSValueRef {.cdecl.} =
  let args = cast[ptr UncheckedArray[JSValueRef]](arguments)
  var ex: JSValueRef = nil
  let sum = JSValueToNumber(ctx, args[0], addr ex) +
            JSValueToNumber(ctx, args[1], addr ex)
  if ex != nil:
    if exception != nil:
      exception[] = ex
    return nil
  JSValueMakeNumber(ctx, sum)

withGlobalContext(ctx):
  var ex: JSValueRef = nil
  let global = JSContextGetGlobalObject(ctx)
  let key = newJSString("add")
  defer: JSStringRelease(key)
  JSObjectSetProperty(ctx, global, key,
    JSObjectMakeFunctionWithCallback(ctx, key, addFn),
    kJSPropertyAttributeNone, addr ex)
  let res = evalScript(ctx, "add(20, 22)", exception = ex)
  var numEx: JSValueRef = nil
  echo JSValueToNumber(ctx, res, addr numEx) # 42.0
```

Define a class with private data from Nim:
```nim
import javascriptcore

withGlobalContext(ctx):
  var def = kJSClassDefinitionEmpty
  def.version = 0
  def.className = "Sentinel"
  let cls = JSClassCreate(addr def)
  defer: JSClassRelease(cls)
  let obj = JSObjectMake(ctx, cls, cast[pointer](0xBEEF))
  JSValueProtect(ctx, obj)
  defer: JSValueUnprotect(ctx, obj)
  assert JSObjectGetPrivate(obj) == cast[pointer](0xBEEF)
  assert JSValueIsObjectOfClass(ctx, obj, cls)
```

### Static linking

Define `jscStatic` to skip the automatic `-framework JavaScriptCore` flags
and supply your own `--passC` / `--passL`. Define `jscNoPkgConfig` for the
same effect on the future Linux build without enabling anything else. The
bindings use the same C API in all link modes; these options do not download
or build JavaScriptCore.

```sh
nim c -r -d:jscStatic \
  --passC:-framework JavaScriptCore \
  --passL:-framework JavaScriptCore \
  tests/test_eval.nim
```

For the planned Linux build, override the WebKitGTK pkg-config name with
`-d:jscPkg=javascriptcoregtk-6.0` (default: `javascriptcoregtk-4.1`).

### Custom static library

Point `-d:jscStaticLib` at your own `libjavascriptcore` archive to link it
directly instead of the system framework. This takes precedence over every
automatic link mode, so no `-framework` flags are emitted. Add
`-d:jscIncludeDir` if its headers live outside the default search path, and
append your own `--passL` flags for any extra native dependencies of your
build (ICU, etc.).

```sh
nim c -r -d:jscStaticLib=/opt/jsc/lib/libjavascriptcore.a \
  -d:jscIncludeDir=/opt/jsc/include \
  --passL:-licuuc --passL:-licui18n \
  tests/test_eval.nim
```

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/nimbase/javascriptcore-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/nimbase/javascriptcore-nim/fork)

### 🎩 License
MIT license | Nim Community.
