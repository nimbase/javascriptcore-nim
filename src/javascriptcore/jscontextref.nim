# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSContextRef.h.
##
## Availability floors from the SDK headers are noted per proc.

import javascriptcore/jsbase

export jsbase

{.push header: jscHeader, importc, cdecl.}

proc JSContextGroupCreate*(): JSContextGroupRef
  ## Creates a context group. macOS 10.6+.

proc JSContextGroupRetain*(group: JSContextGroupRef): JSContextGroupRef
  ## Retains a context group. macOS 10.6+.

proc JSContextGroupRelease*(group: JSContextGroupRef)
  ## Releases a context group. macOS 10.6+.

proc JSGlobalContextCreate*(globalObjectClass: JSClassRef): JSGlobalContextRef
  ## Creates a global context with its own group. Pass nil for the default
  ## object class. macOS 10.5+.

proc JSGlobalContextCreateInGroup*(group: JSContextGroupRef;
                                   globalObjectClass: JSClassRef): JSGlobalContextRef
  ## Creates a global context in `group`. Pass nil group for a unique group.
  ## macOS 10.6+.

proc JSGlobalContextRetain*(ctx: JSGlobalContextRef): JSGlobalContextRef
  ## Retains a global context.

proc JSGlobalContextRelease*(ctx: JSGlobalContextRef)
  ## Releases a global context.

proc JSContextGetGlobalObject*(ctx: JSContextRef): JSObjectRef
  ## Returns the global object. Borrowed.

proc JSContextGetGroup*(ctx: JSContextRef): JSContextGroupRef
  ## Returns the context's group. Borrowed. macOS 10.6+.

proc JSContextGetGlobalContext*(ctx: JSContextRef): JSGlobalContextRef
  ## Returns the global context. Borrowed. macOS 10.7+.

proc JSGlobalContextCopyName*(ctx: JSGlobalContextRef): JSStringRef
  ## Returns the context's debug name. Create Rule. macOS 10.10+.

proc JSGlobalContextSetName*(ctx: JSGlobalContextRef; name: JSStringRef)
  ## Sets the name exposed when inspecting. macOS 10.10+.

proc JSGlobalContextIsInspectable*(ctx: JSGlobalContextRef): bool
  ## Whether the context is inspectable in Web Inspector. macOS 13.3+.

proc JSGlobalContextSetInspectable*(ctx: JSGlobalContextRef;
                                    inspectable: bool)
  ## Sets Web Inspector inspectability. macOS 13.3+.

{.pop.}
