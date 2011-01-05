Namespaces for ruby
===================

It is an experiment to bring namespaces to ruby. It is not quite clear yet
why this would be useful, but it can be interesting nonetheless.

This system is inspired by the CommonJS and Python module systems, adapted
for the ruby particularities.


By loading the .rb files into a temporary
module, it is possible to avoid polluting the global namespace and select what to import
in the current module.

Feature:

* Compatible with ruby 1.8.7 and 1.9.2 (and others?)
* Possible to avoid namespace collision on the module level

Unfeatures:

* uses eval and other nasty ruby hacks
* classes and namespaces don't mix well because "class X; <<here>>; end"
 is a new context that doesn't inherit from it's parent.

TODO
----

* Handle circular dependencies ?
* Avoid eval (but I don't see how)

Tricks
------

A module can emulate the main object behavior by extending itself. In that way,
it makes it's functions directly available to consumption.

    module X
      extend self
      def test
        "x"
      end
      test #=> "x"
    end

TODO

Bikeshed
--------

* Should ruby "namespaced" modules have their own $LOAD_PATH and file extensions ?
* 

Licence
-------

Public domain

Cheers,
  Jonas
