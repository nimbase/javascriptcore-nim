# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSBase.h.
##
## Core opaque types shared by every other module, plus the script
## evaluation entry points (``JSEvaluateScript``, ``JSCheckScriptSyntax``,
## ``JSGarbageCollect``).
##
## Memory management follows the Create Rule: functions with Create/Copy in
## the name return owned references you must release; everything else is
## borrowed or garbage-collected unless documented otherwise.
##
## Note on ``JSValueRef`` vs ``JSObjectRef``: in C both are pointers to
## ``struct OpaqueJSValue`` (const vs non-const). They are the same Nim type,
## so no casts are needed when passing an object where a value is expected.

const jscHeader* = "<JavaScriptCore/JavaScript.h>"
  ## Umbrella C header. On macOS it resolves through the JavaScriptCore
  ## framework; on Linux through the WebKitGTK pkg-config cflags (planned).

type
  OpaqueJSContextGroup* {.importc: "struct OpaqueJSContextGroup",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSContext* {.importc: "struct OpaqueJSContext",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSString* {.importc: "struct OpaqueJSString",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSClass* {.importc: "struct OpaqueJSClass",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSPropertyNameArray* {.importc: "struct OpaqueJSPropertyNameArray",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSPropertyNameAccumulator* {.
      importc: "struct OpaqueJSPropertyNameAccumulator",
      header: jscHeader, incompleteStruct.} = object
  OpaqueJSValue* {.importc: "struct OpaqueJSValue",
      header: jscHeader, incompleteStruct.} = object

type
  JSContextGroupRef* = ptr OpaqueJSContextGroup
    ## A group that associates JavaScript contexts with one another.
  JSContextRef* = ptr OpaqueJSContext
    ## A JavaScript execution context.
  JSGlobalContextRef* = ptr OpaqueJSContext
    ## A global JavaScript execution context. A JSGlobalContext is a JSContext.
  JSStringRef* = ptr OpaqueJSString
    ## A UTF-16 character buffer.
  JSClassRef* = ptr OpaqueJSClass
    ## A JavaScript class, used with JSObjectMake.
  JSPropertyNameArrayRef* = ptr OpaqueJSPropertyNameArray
    ## An array of JavaScript property names.
  JSPropertyNameAccumulatorRef* = ptr OpaqueJSPropertyNameAccumulator
    ## An ordered set used to collect an object's property names.
  JSValueRef* = ptr OpaqueJSValue
    ## A JavaScript value. A JSObjectRef is a JSValueRef.
  JSObjectRef* = ptr OpaqueJSValue
    ## A JavaScript object. A JSObject is a JSValue.
  JSTypedArrayBytesDeallocator* =
    proc(bytes: pointer; deallocatorContext: pointer) {.cdecl.}
    ## Deallocator for bytes handed to a typed-array / array-buffer constructor.

{.push header: jscHeader, importc, cdecl.}

proc JSEvaluateScript*(ctx: JSContextRef; script: JSStringRef;
                       thisObject: JSObjectRef; sourceURL: JSStringRef;
                       startingLineNumber: cint;
                       exception: ptr JSValueRef): JSValueRef
  ## Evaluates a string of JavaScript. Returns the result, or nil when an
  ## exception is thrown (then `exception[]` is set, if `exception` is non-nil).

proc JSCheckScriptSyntax*(ctx: JSContextRef; script: JSStringRef;
                          sourceURL: JSStringRef;
                          startingLineNumber: cint;
                          exception: ptr JSValueRef): bool
  ## Checks for syntax errors. Returns true when the script is valid.

proc JSGarbageCollect*(ctx: JSContextRef)
  ## Performs a JavaScript garbage collection.

{.pop.}
