How to use
==========

The main difference between :code:`module-graph` and other tools based
on :code:`ocamldep` is that :code:`module-graph` does not need to
understand how your project is built: it just scans the directories
looking for binary objects and computes the links between them.

In your project, just run::

  $ module-graph
  Generated 23 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

By default, :code:`module-graph` scans the current directory and its
sub-directories, looking for :code:`.cmt/.cmti` files. It only ignores the
`_opam/` sub-directory.

You can specify another set of directories to scan::

  $ module-graph _build/default/src/parsers
  Generated 6 edges in "deps.dot" and "deps.pdf"

You can change the format of the generated file with :code:`-T/--format
FORMAT`::

  $ module-graph --format png
  Generated 23 edges in "deps.dot" and "deps.png"
  $ display deps.png

You can change the name of the generated file with :code:`-o/--output
BASENAME`::

  $ module-graph -o alt-ergo-deps
  Generated 23 edges in "alt-ergo-deps.dot" and "alt-ergo-deps.pdf"
  $ evince alt-ergo-deps.pdf

In some cases, :code:`.cmt`/`.cmti` files are not available, so you may want
to use :code:`.cmi` files with :code:`--cmi`::

  $ module-graph --cmi
  Generated 21 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

By default, :code:`module-graph` drops direct links between modules if these
links are implied by transitive dependencies. You can keep them with
`-A/--all-links`::

  $ module-graph --all-links
  Generated 32 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

If modules are packed/wrapped within a module (default behavior for
`dune`), you may use the :code:`-R/--remove-pack MODNAME` to filter modules
(keeping only the ones within the pack) and remove the corresponding
prefix::

  $ module-graph --remove-pack AltErgoLib
  Generated 19 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

You can display the filenames in the grap instead of the module names
using the :code:`--filenames` option::

  $ module-graph --filenames
  Generated 23 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

You can filter out modules using a regexp with :code:`-X/--ignore-module
REGEXP` where regexp is in the glob format::

  $ module-graph -X 'AltErgoLib__*'
  Generated 3 edges in "deps.dot" and "deps.pdf"
  $ evince deps.pdf

Examples
--------

.. |module-graph-deps| image:: //module-graph/assets/images/module-graph-deps.png

* Raw Dependencies for :code:`module-graph`:
 |module-graph-deps|

.. |module-graph-deps-all| image:: //module-graph/assets/images/module-graph-deps-all.png

* All Dependencies for :code:`module-graph` (:code:`--all-links`):
 |module-graph-deps-all|

.. |alt-ergo-deps| image:: //module-graph/assets/images/alt-ergo-deps.png

* Raw Dependencies for :code:`alt-ergo`:
 |alt-ergo-deps|

.. |alt-ergo-deps-pack| image:: //module-graph/assets/images/alt-ergo-deps-pack.png

* Dependencies restricted to :code:`AltErgoLib` for :code:`alt-ergo` (:code:`--remove-pack AltErgoLib`):
 |alt-ergo-deps-pack|
