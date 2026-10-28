import std/unittest

import javascriptcore

test "make typed array and query it":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let arr = JSObjectMakeTypedArray(ctx, kJSTypedArrayTypeFloat64Array, 4,
                                     addr ex)
    check ex == nil
    check arr != nil
    check JSValueIsObject(ctx, arr)
    var ex2: JSValueRef = nil
    check JSValueGetTypedArrayType(ctx, arr, addr ex2) ==
      kJSTypedArrayTypeFloat64Array
    check ex2 == nil
    check JSObjectGetTypedArrayLength(ctx, arr, addr ex) == 4
    check ex == nil
    check JSObjectGetTypedArrayByteLength(ctx, arr, addr ex) == 32
    check JSObjectGetTypedArrayByteOffset(ctx, arr, addr ex) == 0
    let buf = JSObjectGetTypedArrayBuffer(ctx, arr, addr ex)
    check ex == nil
    check buf != nil
    check JSValueGetTypedArrayType(ctx, buf, addr ex) ==
      kJSTypedArrayTypeArrayBuffer

test "non typed array reports none":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let plain = evalScript(ctx, "({})", exception = ex)
    check ex == nil
    check JSValueGetTypedArrayType(ctx, plain, addr ex) ==
      kJSTypedArrayTypeNone

proc freeBytes(bytes: pointer; context: pointer) {.cdecl.} =
  dealloc(bytes)

test "arraybuffer with external bytes":
  withGlobalContext(ctx):
    var ex: JSValueRef = nil
    let raw = alloc0(16)
    let buf = JSObjectMakeArrayBufferWithBytesNoCopy(ctx, raw, 16, freeBytes,
        nil, addr ex)
    check ex == nil
    check buf != nil
    check JSObjectGetArrayBufferByteLength(ctx, buf, addr ex) == 16
    check ex == nil
    check JSObjectGetArrayBufferBytesPtr(ctx, buf, addr ex) != nil
    check ex == nil
    # Back the typed array off the same buffer with an offset.
    let view = JSObjectMakeTypedArrayWithArrayBufferAndOffset(
      ctx, kJSTypedArrayTypeUint8Array, buf, 4, 8, addr ex)
    check ex == nil
    check JSObjectGetTypedArrayLength(ctx, view, addr ex) == 8
    check JSObjectGetTypedArrayByteOffset(ctx, view, addr ex) == 4
