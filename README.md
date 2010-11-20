Namespaces for ruby <hack>
==========================

Brings a namespace system to ruby. By loading the .rb files into a temporary
module, it is possible to avoid polluting the global namespace and select what to import
in the current module.

This system is inspired by the CommonJS module system, but it was adapted
for the ruby particularities.

Feature:
* Possible to avoid namespace collision on the module level
* Relative requires (if import is used in the top-level of the file)

Unfeatures:
* uses eval and other nasty ruby hacks
* classes and namespaces don't mix well because "class X; <<here>>; end"
 is a new context that doesn't inherit from it's parent.

TODO
----

* Handle circular dependencies ?
* Avoid eval (but I don't see how)

Bikeshed
--------

* Should ruby "namespaced" modules have their own $LOAD_PATH and file extensions ?

Licence
-------

Public domain

Cheers,
  Jonas