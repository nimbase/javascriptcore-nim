# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSTypedArray.h (typed arrays + array buffers).
##
## The ``JSTypedArrayType`` enum itself lives in ``jsvalueref`` (as in C,
## where it is declared in JSValueRef.h). Everything here is macOS 10.12+.

import javascriptcore/jsbase
import javascriptcore/jsvalueref

export jsbase
export jsvalueref

{.push header: jscHeader, importc, cdecl.}

proc JSObjectMakeTypedArray*(ctx: JSContextRef; arrayType: JSTypedArrayType;
                             length: csize_t;
                             exception: ptr JSValueRef): JSObjectRef
  ## Zero-filled. Nil for None/ArrayBuffer types or on error.

proc JSObjectMakeTypedArrayWithBytesNoCopy*(
    ctx: JSContextRef; arrayType: JSTypedArrayType; bytes: pointer;
    byteLength: csize_t; bytesDeallocator: JSTypedArrayBytesDeallocator;
    deallocatorContext: pointer; exception: ptr JSValueRef): JSObjectRef
  ## Takes over `bytes`; the deallocator always runs, even on failure.

proc JSObjectMakeTypedArrayWithArrayBuffer*(ctx: JSContextRef;
    arrayType: JSTypedArrayType; buffer: JSObjectRef;
    exception: ptr JSValueRef): JSObjectRef

proc JSObjectMakeTypedArrayWithArrayBufferAndOffset*(
    ctx: JSContextRef; arrayType: JSTypedArrayType; buffer: JSObjectRef;
    byteOffset: csize_t; length: csize_t;
    exception: ptr JSValueRef): JSObjectRef

proc JSObjectGetTypedArrayBytesPtr*(ctx: JSContextRef; obj: JSObjectRef;
                                    exception: ptr JSValueRef): pointer
  ## Temporary pointer; may not survive further JS API calls. Nil unless
  ## `obj` is a typed array.

proc JSObjectGetTypedArrayLength*(ctx: JSContextRef; obj: JSObjectRef;
                                  exception: ptr JSValueRef): csize_t
  ## Element count, or 0.

proc JSObjectGetTypedArrayByteLength*(ctx: JSContextRef; obj: JSObjectRef;
                                      exception: ptr JSValueRef): csize_t

proc JSObjectGetTypedArrayByteOffset*(ctx: JSContextRef; obj: JSObjectRef;
                                      exception: ptr JSValueRef): csize_t

proc JSObjectGetTypedArrayBuffer*(ctx: JSContextRef; obj: JSObjectRef;
                                  exception: ptr JSValueRef): JSObjectRef
  ## Backing ArrayBuffer, or nil.

proc JSObjectMakeArrayBufferWithBytesNoCopy*(
    ctx: JSContextRef; bytes: pointer; byteLength: csize_t;
    bytesDeallocator: JSTypedArrayBytesDeallocator;
    deallocatorContext: pointer; exception: ptr JSValueRef): JSObjectRef
  ## Takes over `bytes`; the deallocator always runs, even on failure.

proc JSObjectGetArrayBufferBytesPtr*(ctx: JSContextRef; obj: JSObjectRef;
                                      exception: ptr JSValueRef): pointer
  ## Temporary pointer. Nil unless `obj` is an ArrayBuffer.

proc JSObjectGetArrayBufferByteLength*(ctx: JSContextRef; obj: JSObjectRef;
                                       exception: ptr JSValueRef): csize_t

{.pop.}
