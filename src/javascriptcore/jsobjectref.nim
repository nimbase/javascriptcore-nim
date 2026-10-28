# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSObjectRef.h.
##
## Classes, callbacks, properties, functions, constructors and promises.
## Availability floors from the SDK headers are noted per item.
##
## Struct layout mirrors ``JSClassDefinition`` exactly (version first,
## ``convertToType`` last); ``completeStruct`` keeps it honest.

import javascriptcore/jsbase
import javascriptcore/jsvalueref

export jsbase
export jsvalueref

type
  JSPropertyAttributes* = cuint
    ## Bitmask of kJSPropertyAttribute* flags.
  JSClassAttributes* = cuint
    ## Bitmask of kJSClassAttribute* flags.

const
  kJSPropertyAttributeNone* = JSPropertyAttributes(0)
  kJSPropertyAttributeReadOnly* = JSPropertyAttributes(2)
  kJSPropertyAttributeDontEnum* = JSPropertyAttributes(4)
  kJSPropertyAttributeDontDelete* = JSPropertyAttributes(8)
  kJSClassAttributeNone* = JSClassAttributes(0)
  kJSClassAttributeNoAutomaticPrototype* = JSClassAttributes(2)

type
  JSObjectInitializeCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef) {.cdecl.}
  JSObjectFinalizeCallback* =
    proc(obj: JSObjectRef) {.cdecl.}
    ## No JS API calls allowed inside (any thread, GC-unsafe).
  JSObjectHasPropertyCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef;
         propertyName: JSStringRef): bool {.cdecl.}
  JSObjectGetPropertyCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef; propertyName: JSStringRef;
         exception: ptr JSValueRef): JSValueRef {.cdecl.}
  JSObjectSetPropertyCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef; propertyName: JSStringRef;
         value: JSValueRef; exception: ptr JSValueRef): bool {.cdecl.}
  JSObjectDeletePropertyCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef; propertyName: JSStringRef;
         exception: ptr JSValueRef): bool {.cdecl.}
  JSObjectGetPropertyNamesCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef;
         propertyNames: JSPropertyNameAccumulatorRef) {.cdecl.}
  JSObjectCallAsFunctionCallback* =
    proc(ctx: JSContextRef; function: JSObjectRef; thisObject: JSObjectRef;
         argumentCount: csize_t; arguments: ptr JSValueRef;
         exception: ptr JSValueRef): JSValueRef {.cdecl.}
  JSObjectCallAsConstructorCallback* =
    proc(ctx: JSContextRef; constructor: JSObjectRef;
         argumentCount: csize_t; arguments: ptr JSValueRef;
         exception: ptr JSValueRef): JSObjectRef {.cdecl.}
  JSObjectHasInstanceCallback* =
    proc(ctx: JSContextRef; constructor: JSObjectRef;
         possibleInstance: JSValueRef;
         exception: ptr JSValueRef): bool {.cdecl.}
  JSObjectConvertToTypeCallback* =
    proc(ctx: JSContextRef; obj: JSObjectRef; kind: JSType;
         exception: ptr JSValueRef): JSValueRef {.cdecl.}

type
  JSStaticValue* {.bycopy, completeStruct.} = object
    name*: cstring
    getProperty*: JSObjectGetPropertyCallback
    setProperty*: JSObjectSetPropertyCallback
    attributes*: JSPropertyAttributes

  JSStaticFunction* {.bycopy, completeStruct.} = object
    name*: cstring
    callAsFunction*: JSObjectCallAsFunctionCallback
    attributes*: JSPropertyAttributes

  JSClassDefinition* {.bycopy, completeStruct.} = object
    version*: cint
    attributes*: JSClassAttributes
    className*: cstring
    parentClass*: JSClassRef
    staticValues*: ptr JSStaticValue
    staticFunctions*: ptr JSStaticFunction
    initialize*: JSObjectInitializeCallback
    finalize*: JSObjectFinalizeCallback
    hasProperty*: JSObjectHasPropertyCallback
    getProperty*: JSObjectGetPropertyCallback
    setProperty*: JSObjectSetPropertyCallback
    deleteProperty*: JSObjectDeletePropertyCallback
    getPropertyNames*: JSObjectGetPropertyNamesCallback
    callAsFunction*: JSObjectCallAsFunctionCallback
    callAsConstructor*: JSObjectCallAsConstructorCallback
    hasInstance*: JSObjectHasInstanceCallback
    convertToType*: JSObjectConvertToTypeCallback

const kJSClassDefinitionEmpty* = JSClassDefinition(
  version: 0,
  attributes: kJSClassAttributeNone,
  className: nil,
  parentClass: nil,
  staticValues: nil,
  staticFunctions: nil,
  initialize: nil,
  finalize: nil,
  hasProperty: nil,
  getProperty: nil,
  setProperty: nil,
  deleteProperty: nil,
  getPropertyNames: nil,
  callAsFunction: nil,
  callAsConstructor: nil,
  hasInstance: nil,
  convertToType: nil)
  ## Zero definition, version 0. Copy before filling in. (C also exports
  ## this as an extern const; this Nim const is its zero value.)

{.push header: jscHeader, importc, cdecl.}

proc JSClassCreate*(definition: ptr JSClassDefinition): JSClassRef
  ## Create Rule.

proc JSClassRetain*(jsClass: JSClassRef): JSClassRef
proc JSClassRelease*(jsClass: JSClassRef)

proc JSObjectMake*(ctx: JSContextRef; jsClass: JSClassRef;
                   data: pointer): JSObjectRef
  ## Nil class uses the default object class. `data` needs a non-nil class
  ## to be stored; readable via GetPrivate.

proc JSObjectMakeFunctionWithCallback*(ctx: JSContextRef; name: JSStringRef;
    callAsFunction: JSObjectCallAsFunctionCallback): JSObjectRef
  ## Nil name makes an anonymous function.

proc JSObjectMakeConstructor*(ctx: JSContextRef; jsClass: JSClassRef;
    callAsConstructor: JSObjectCallAsConstructorCallback): JSObjectRef

proc JSObjectMakeArray*(ctx: JSContextRef; argumentCount: csize_t;
                        arguments: ptr JSValueRef;
                        exception: ptr JSValueRef): JSObjectRef
  ## macOS 10.6+. One argument makes a one-element array (unlike ``new Array``).

proc JSObjectMakeDate*(ctx: JSContextRef; argumentCount: csize_t;
                       arguments: ptr JSValueRef;
                       exception: ptr JSValueRef): JSObjectRef
  ## macOS 10.6+.

proc JSObjectMakeError*(ctx: JSContextRef; argumentCount: csize_t;
                        arguments: ptr JSValueRef;
                        exception: ptr JSValueRef): JSObjectRef
  ## macOS 10.6+.

proc JSObjectMakeRegExp*(ctx: JSContextRef; argumentCount: csize_t;
                         arguments: ptr JSValueRef;
                         exception: ptr JSValueRef): JSObjectRef
  ## macOS 10.6+.

proc JSObjectMakeDeferredPromise*(ctx: JSContextRef;
                                  resolve: ptr JSObjectRef;
                                  reject: ptr JSObjectRef;
                                  exception: ptr JSValueRef): JSObjectRef
  ## `resolve`/`reject` may each be nil if unneeded. macOS 10.15+.

proc JSObjectMakeFunction*(ctx: JSContextRef; name: JSStringRef;
                           parameterCount: cuint;
                           parameterNames: ptr JSStringRef; body: JSStringRef;
                           sourceURL: JSStringRef; startingLineNumber: cint;
                           exception: ptr JSValueRef): JSObjectRef
  ## Builds a function from source. Nil on syntax error.

proc JSObjectGetPrototype*(ctx: JSContextRef; obj: JSObjectRef): JSValueRef
proc JSObjectSetPrototype*(ctx: JSContextRef; obj: JSObjectRef;
                           value: JSValueRef)

proc JSObjectHasProperty*(ctx: JSContextRef; obj: JSObjectRef;
                          propertyName: JSStringRef): bool
proc JSObjectGetProperty*(ctx: JSContextRef; obj: JSObjectRef;
                          propertyName: JSStringRef;
                          exception: ptr JSValueRef): JSValueRef
proc JSObjectSetProperty*(ctx: JSContextRef; obj: JSObjectRef;
                          propertyName: JSStringRef; value: JSValueRef;
                          attributes: JSPropertyAttributes;
                          exception: ptr JSValueRef)
proc JSObjectDeleteProperty*(ctx: JSContextRef; obj: JSObjectRef;
                             propertyName: JSStringRef;
                             exception: ptr JSValueRef): bool

proc JSObjectHasPropertyForKey*(ctx: JSContextRef; obj: JSObjectRef;
                                propertyKey: JSValueRef;
                                exception: ptr JSValueRef): bool
  ## ``propertyKey in object``. macOS 10.15+.

proc JSObjectGetPropertyForKey*(ctx: JSContextRef; obj: JSObjectRef;
                                propertyKey: JSValueRef;
                                exception: ptr JSValueRef): JSValueRef
  ## ``object[propertyKey]``. macOS 10.15+.

proc JSObjectSetPropertyForKey*(ctx: JSContextRef; obj: JSObjectRef;
                                propertyKey: JSValueRef; value: JSValueRef;
                                attributes: JSPropertyAttributes;
                                exception: ptr JSValueRef)
  ## ``object[propertyKey] = value``. macOS 10.15+.

proc JSObjectDeletePropertyForKey*(ctx: JSContextRef; obj: JSObjectRef;
                                   propertyKey: JSValueRef;
                                   exception: ptr JSValueRef): bool
  ## macOS 10.15+.

proc JSObjectGetPropertyAtIndex*(ctx: JSContextRef; obj: JSObjectRef;
                                 propertyIndex: cuint;
                                 exception: ptr JSValueRef): JSValueRef
proc JSObjectSetPropertyAtIndex*(ctx: JSContextRef; obj: JSObjectRef;
                                 propertyIndex: cuint; value: JSValueRef;
                                 exception: ptr JSValueRef)

proc JSObjectGetPrivate*(obj: JSObjectRef): pointer
  ## Borrowed private data, or nil.

proc JSObjectSetPrivate*(obj: JSObjectRef; data: pointer): bool
  ## False when the class stores no private data.

proc JSObjectIsFunction*(ctx: JSContextRef; obj: JSObjectRef): bool

proc JSObjectCallAsFunction*(ctx: JSContextRef; obj: JSObjectRef;
                             thisObject: JSObjectRef;
                             argumentCount: csize_t;
                             arguments: ptr JSValueRef;
                             exception: ptr JSValueRef): JSValueRef
  ## Nil `thisObject` uses the global object. Nil on exception/not-a-function.

proc JSObjectIsConstructor*(ctx: JSContextRef; obj: JSObjectRef): bool

proc JSObjectCallAsConstructor*(ctx: JSContextRef; obj: JSObjectRef;
                                argumentCount: csize_t;
                                arguments: ptr JSValueRef;
                                exception: ptr JSValueRef): JSObjectRef

proc JSObjectCopyPropertyNames*(ctx: JSContextRef;
                                obj: JSObjectRef): JSPropertyNameArrayRef
  ## Create Rule.

proc JSPropertyNameArrayRetain*(array: JSPropertyNameArrayRef): JSPropertyNameArrayRef
proc JSPropertyNameArrayRelease*(array: JSPropertyNameArrayRef)

proc JSPropertyNameArrayGetCount*(array: JSPropertyNameArrayRef): csize_t

proc JSPropertyNameArrayGetNameAtIndex*(array: JSPropertyNameArrayRef;
                                        index: csize_t): JSStringRef
  ## Borrowed: valid while `array` lives. Do not release.

proc JSPropertyNameAccumulatorAddName*(
    accumulator: JSPropertyNameAccumulatorRef; propertyName: JSStringRef)
  ## For use inside getPropertyNames callbacks.

{.pop.}
