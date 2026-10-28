# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSValueRef.h.
##
## ``JSTypedArrayType`` and ``JSRelationCondition`` also live here in C
## (``JSTypedArray.h`` only holds functions). Availability floors from the
## SDK headers are noted per item.

import javascriptcore/jsbase

export jsbase

type
  JSType* {.size: 4.} = enum
    kJSTypeUndefined = 0
    kJSTypeNull = 1
    kJSTypeBoolean = 2
    kJSTypeNumber = 3
    kJSTypeString = 4
    kJSTypeObject = 5
    kJSTypeSymbol = 6 ## macOS 10.15+
    kJSTypeBigInt = 7 ## macOS 15.0+

  JSTypedArrayType* {.size: 4.} = enum
    kJSTypedArrayTypeInt8Array = 0
    kJSTypedArrayTypeInt16Array = 1
    kJSTypedArrayTypeInt32Array = 2
    kJSTypedArrayTypeUint8Array = 3
    kJSTypedArrayTypeUint8ClampedArray = 4
    kJSTypedArrayTypeUint16Array = 5
    kJSTypedArrayTypeUint32Array = 6
    kJSTypedArrayTypeFloat32Array = 7
    kJSTypedArrayTypeFloat64Array = 8
    kJSTypedArrayTypeArrayBuffer = 9
    kJSTypedArrayTypeNone = 10
    kJSTypedArrayTypeBigInt64Array = 11
    kJSTypedArrayTypeBigUint64Array = 12
    ## macOS 10.12+.

  JSRelationCondition* {.size: 4.} = enum
    kJSRelationConditionUndefined = 0
    kJSRelationConditionEqual = 1
    kJSRelationConditionGreaterThan = 2
    kJSRelationConditionLessThan = 3
    ## Result of JSValueCompare. macOS 15.0+.

{.push header: jscHeader, importc, cdecl.}

proc JSValueGetType*(ctx: JSContextRef; value: JSValueRef): JSType
  ## Returns a value's type.

proc JSValueIsUndefined*(ctx: JSContextRef; value: JSValueRef): bool
proc JSValueIsNull*(ctx: JSContextRef; value: JSValueRef): bool
proc JSValueIsBoolean*(ctx: JSContextRef; value: JSValueRef): bool
proc JSValueIsNumber*(ctx: JSContextRef; value: JSValueRef): bool
proc JSValueIsString*(ctx: JSContextRef; value: JSValueRef): bool

proc JSValueIsSymbol*(ctx: JSContextRef; value: JSValueRef): bool
  ## macOS 10.15+.

proc JSValueIsBigInt*(ctx: JSContextRef; value: JSValueRef): bool
  ## macOS 15.0+.

proc JSValueIsObject*(ctx: JSContextRef; value: JSValueRef): bool

proc JSValueIsObjectOfClass*(ctx: JSContextRef; value: JSValueRef;
                             jsClass: JSClassRef): bool
  ## Tests class membership along the class chain.

proc JSValueIsArray*(ctx: JSContextRef; value: JSValueRef): bool
  ## macOS 10.11+.

proc JSValueIsDate*(ctx: JSContextRef; value: JSValueRef): bool
  ## macOS 10.11+.

proc JSValueGetTypedArrayType*(ctx: JSContextRef; value: JSValueRef;
                               exception: ptr JSValueRef): JSTypedArrayType
  ## Returns the typed-array type, or kJSTypedArrayTypeNone. macOS 10.12+.

proc JSValueIsEqual*(ctx: JSContextRef; a, b: JSValueRef;
                     exception: ptr JSValueRef): bool
  ## ``==`` comparison.

proc JSValueIsStrictEqual*(ctx: JSContextRef; a, b: JSValueRef): bool
  ## ``===`` comparison.

proc JSValueIsInstanceOfConstructor*(ctx: JSContextRef; value: JSValueRef;
                                     constructor: JSObjectRef;
                                     exception: ptr JSValueRef): bool
  ## ``instanceof`` comparison.

proc JSValueCompare*(ctx: JSContextRef; left, right: JSValueRef;
                     exception: ptr JSValueRef): JSRelationCondition
  ## Compares two values. Undefined on exception or NaN. macOS 15.0+.

proc JSValueCompareInt64*(ctx: JSContextRef; left: JSValueRef; right: int64;
                          exception: ptr JSValueRef): JSRelationCondition
  ## macOS 15.0+.

proc JSValueCompareUInt64*(ctx: JSContextRef; left: JSValueRef; right: uint64;
                           exception: ptr JSValueRef): JSRelationCondition
  ## macOS 15.0+.

proc JSValueCompareDouble*(ctx: JSContextRef; left: JSValueRef; right: cdouble;
                           exception: ptr JSValueRef): JSRelationCondition
  ## macOS 15.0+.

proc JSValueMakeUndefined*(ctx: JSContextRef): JSValueRef
proc JSValueMakeNull*(ctx: JSContextRef): JSValueRef
proc JSValueMakeBoolean*(ctx: JSContextRef; boolean: bool): JSValueRef
proc JSValueMakeNumber*(ctx: JSContextRef; number: cdouble): JSValueRef

proc JSValueMakeString*(ctx: JSContextRef; str: JSStringRef): JSValueRef
  ## Retains `str`; released on collection.

proc JSValueMakeSymbol*(ctx: JSContextRef;
                        description: JSStringRef): JSValueRef
  ## macOS 10.15+.

proc JSBigIntCreateWithDouble*(ctx: JSContextRef; value: cdouble;
                               exception: ptr JSValueRef): JSValueRef
  ## Throws unless the double is integral. macOS 15.0+.

proc JSBigIntCreateWithInt64*(ctx: JSContextRef; integer: int64;
                              exception: ptr JSValueRef): JSValueRef
  ## macOS 15.0+.

proc JSBigIntCreateWithUInt64*(ctx: JSContextRef; integer: uint64;
                               exception: ptr JSValueRef): JSValueRef
  ## macOS 15.0+.

proc JSBigIntCreateWithString*(ctx: JSContextRef; str: JSStringRef;
                               exception: ptr JSValueRef): JSValueRef
  ## Like calling the ``BigInt`` constructor on a string. macOS 15.0+.

proc JSValueMakeFromJSONString*(ctx: JSContextRef;
                                str: JSStringRef): JSValueRef
  ## Parses JSON. Returns nil on invalid input. macOS 10.7+.

proc JSValueCreateJSONString*(ctx: JSContextRef; value: JSValueRef;
                              indent: cuint;
                              exception: ptr JSValueRef): JSStringRef
  ## Serializes to JSON. Create Rule. `indent` clamps to 10. macOS 10.7+.

proc JSValueToBoolean*(ctx: JSContextRef; value: JSValueRef): bool

proc JSValueToNumber*(ctx: JSContextRef; value: JSValueRef;
                      exception: ptr JSValueRef): cdouble
  ## Like ``Number(value)``. NaN on exception.

proc JSValueToInt32*(ctx: JSContextRef; value: JSValueRef;
                     exception: ptr JSValueRef): int32
  ## 0 is a valid result: check `exception[]`. macOS 15.0+.

proc JSValueToUInt32*(ctx: JSContextRef; value: JSValueRef;
                      exception: ptr JSValueRef): uint32
  ## macOS 15.0+.

proc JSValueToInt64*(ctx: JSContextRef; value: JSValueRef;
                     exception: ptr JSValueRef): int64
  ## macOS 15.0+.

proc JSValueToUInt64*(ctx: JSContextRef; value: JSValueRef;
                      exception: ptr JSValueRef): uint64
  ## macOS 15.0+.

proc JSValueToStringCopy*(ctx: JSContextRef; value: JSValueRef;
                          exception: ptr JSValueRef): JSStringRef
  ## Create Rule. Nil on exception.

proc JSValueToObject*(ctx: JSContextRef; value: JSValueRef;
                      exception: ptr JSValueRef): JSObjectRef
  ## Nil on exception.

proc JSValueProtect*(ctx: JSContextRef; value: JSValueRef)
  ## Pins a value against GC. Pair every call with Unprotect.

proc JSValueUnprotect*(ctx: JSContextRef; value: JSValueRef)
  ## Releases one Protect hold.

{.pop.}
