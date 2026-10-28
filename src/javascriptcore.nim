# Nim bindings to JavaScriptCore (Apple's JavaScript engine).
#
# MIT License.
#
# (c) 2026 Nimbase Community

## Low-level Nim bindings for JavaScriptCore, Apple's JavaScript engine.
##
## C names are preserved verbatim so upstream code stays greppable.
## Uses the JavaScriptCore framework on macOS.
##
## Basic example:
##
## ```nim
## import javascriptcore
##
## withGlobalContext(ctx):
##   var ex: JSValueRef = nil
##   let res = evalScript(ctx, "1 + 2", exception = ex)
##   assert ex == nil
##   var ex2: JSValueRef = nil
##   assert JSValueToNumber(ctx, res, addr ex2) == 3.0
## ```
##
## The raw API (``JSEvaluateScript``, ``JSObjectMakeFunctionWithCallback``,
## ...) returns exactly what C returns, including nil on failure: always
## check the ``exception`` out-param. ``helpers`` adds ``newJSString``,
## ``$``, ``evalScript`` and ``withGlobalContext`` on top.
##
## Define ``jscStatic`` (or ``jscNoPkgConfig``) to skip the automatic link
## flags and supply your own. Define ``jscStaticLib`` with the path to a
## custom static ``libjavascriptcore`` archive to link it directly
## (``jscIncludeDir`` optionally points at its headers).

import std/os

const jscStaticLib* {.strdefine.} = ""
  ## Path to a custom static JavaScriptCore archive, e.g.
  ## `-d:jscStaticLib=/opt/jsc/lib/libjavascriptcore.a`.
  ## Takes precedence over every automatic link mode below. Extra native
  ## dependencies of your build (ICU, etc.) still need their own `--passL`.
const jscIncludeDir* {.strdefine.} = ""
  ## Extra C include dir for the JavaScriptCore headers, e.g.
  ## `-d:jscIncludeDir=/opt/jsc/include`. Applies in every link mode.

when jscIncludeDir.len > 0:
  {.passC: "-I" & quoteShell(jscIncludeDir).}

when jscStaticLib.len > 0:
  {.passL: quoteShell(jscStaticLib).}
elif defined(jscStatic) or defined(jscNoPkgConfig):
  discard # Caller supplies --passC/--passL.
elif defined(macosx):
  {.passC: "-framework JavaScriptCore".}
  {.passL: "-framework JavaScriptCore".}
else:
  # Linux via WebKitGTK. Untested; planned. Override with -d:jscPkg=....
  const jscPkg {.strdefine.} = "javascriptcoregtk-4.1"
  {.passC: gorge("pkg-config --cflags " & jscPkg).}
  {.passL: gorge("pkg-config --libs " & jscPkg).}

# Callback signatures are ABI-identical to C (pointer-sized opaques) but
# differ nominally (Nim spellings vs C tags incl. const), which clang 16+
# escalates to a hard error when Nim procs are registered as C callbacks.
# Demote back to a warning; register Nim callbacks directly, no casts.
when not defined(jscStatic):
  {.passC: "-Wno-incompatible-function-pointer-types".}

import javascriptcore/jsbase
import javascriptcore/jsstringref
import javascriptcore/jscontextref
import javascriptcore/jsvalueref
import javascriptcore/jsobjectref
import javascriptcore/jstypedarray
import javascriptcore/helpers

export jsbase
export jsstringref
export jscontextref
export jsvalueref
export jsobjectref
export jstypedarray
export helpers

when defined(macosx):
  import javascriptcore/jsstringrefcf
  export jsstringrefcf
