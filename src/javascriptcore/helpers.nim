# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License.

## Thin ergonomic helpers over the raw bindings.
##
## The per-header modules stay verbatim C. This module adds the four things
## almost every caller needs: UTF-8 string conversion both ways, one-shot
## script evaluation, and scoped context lifetime.

import javascriptcore/jsbase
import javascriptcore/jsstringref
import javascriptcore/jscontextref
import javascriptcore/jsvalueref
import javascriptcore/jsobjectref

export jsbase
export jsstringref
export jscontextref
export jsvalueref
export jsobjectref

proc newJSString*(s: string): JSStringRef =
  ## Wraps `s` in a JSString. Owned: release with ``JSStringRelease``.
  JSStringCreateWithUTF8CString(s)

proc `$`*(str: JSStringRef): string =
  ## Converts a JSString to a Nim UTF-8 string. Never fails; nil gives "".
  if str == nil:
    return ""
  let maxSize = int(JSStringGetMaximumUTF8CStringSize(str))
  if maxSize <= 1:
    return ""
  result = newString(maxSize)
  let written = int(JSStringGetUTF8CString(str, cast[cstring](addr result[0]),
      csize_t(maxSize)))
  result.setLen(max(written - 1, 0))

proc evalScript*(ctx: JSContextRef; script: string;
                 thisObject: JSObjectRef = nil; sourceURL: string = "";
                 line: int = 1; exception: var JSValueRef): JSValueRef =
  ## Evaluates `script` and returns the result (nil on exception, with
  ## `exception[]` set). `exception` must be initialized to nil by the caller.
  let jsScript = newJSString(script)
  defer: JSStringRelease(jsScript)
  var jsURL: JSStringRef = nil
  if sourceURL.len > 0:
    jsURL = newJSString(sourceURL)
    defer: JSStringRelease(jsURL)
  result = JSEvaluateScript(ctx, jsScript, thisObject, jsURL, cint(line),
                            addr exception)

template withGlobalContext*(ctx: untyped; body: untyped) =
  ## Creates a global context, runs `body`, releases it.
  ## Usage: ``withGlobalContext(ctx): ...``.
  let ctx = JSGlobalContextCreate(nil)
  try:
    body
  finally:
    JSGlobalContextRelease(ctx)
