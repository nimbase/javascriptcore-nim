# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSStringRefCF.h (macOS only).
##
## Two CFString convenience functions. There is no Linux WebKitGTK
## equivalent, so this module is only available on macOS.
## ``CFAllocatorRef``/``CFStringRef`` are opaque here; import a real
## CoreFoundation binding if you need to do more with them.

import javascriptcore/jsbase

export jsbase

const jscCFHeader* = "<JavaScriptCore/JSStringRefCF.h>"

type
  CFAllocatorRef* = ptr object
    ## Opaque CoreFoundation allocator.
  CFStringRef* = ptr object
    ## Opaque CoreFoundation string.

{.push header: jscCFHeader, importc, cdecl.}

proc JSStringCreateWithCFString*(str: CFStringRef): JSStringRef
  ## Create Rule.

proc JSStringCopyCFString*(alloc: CFAllocatorRef;
                           str: JSStringRef): CFStringRef
  ## Create Rule (CF_RETURNS_RETAINED). Pass nil `alloc` for the default.

{.pop.}
