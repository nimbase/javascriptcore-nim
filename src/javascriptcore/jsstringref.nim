# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License. C names are preserved verbatim so upstream code stays greppable.

## Bindings for JSStringRef.h.

import javascriptcore/jsbase

export jsbase

type
  JSChar* = uint16
    ## A UTF-16 code unit. (On macOS ``JSChar`` is ``unsigned short``;
    ## the ``wchar_t`` branch only applies to MSVC-like targets we skip.)

{.push header: jscHeader, importc, cdecl.}

proc JSStringCreateWithCharacters*(chars: ptr JSChar;
                                   numChars: csize_t): JSStringRef
  ## Creates a string from a UTF-16 buffer. Ownership follows the Create Rule.

proc JSStringCreateWithUTF8CString*(str: cstring): JSStringRef
  ## Creates a string from a null-terminated UTF-8 string. Create Rule.

proc JSStringRetain*(str: JSStringRef): JSStringRef
  ## Retains a string.

proc JSStringRelease*(str: JSStringRef)
  ## Releases a string.

proc JSStringGetLength*(str: JSStringRef): csize_t
  ## Returns the length in UTF-16 code units (not bytes, not graphemes).

proc JSStringGetCharactersPtr*(str: JSStringRef): ptr JSChar
  ## Returns the borrowed backing buffer. Valid until `str` is released.

proc JSStringGetMaximumUTF8CStringSize*(str: JSStringRef): csize_t
  ## Upper bound (in bytes, including the NUL) for the UTF-8 conversion.

proc JSStringGetUTF8CString*(str: JSStringRef; buffer: cstring;
                             bufferSize: csize_t): csize_t
  ## Copies the NUL-terminated UTF-8 form into `buffer`. Returns bytes
  ## written including the NUL. Partial on a too-small buffer.

proc JSStringIsEqual*(a, b: JSStringRef): bool
  ## Tests whether two strings match.

proc JSStringIsEqualToUTF8CString*(a: JSStringRef; b: cstring): bool
  ## Tests whether a string matches a NUL-terminated UTF-8 string.

{.pop.}
