About
=====

The module-graph tool generates a graph of dependencies between OCaml modules using compiled object files. module-graph scans the current directory and sub-directories looking for .cmt/.cmti/.cmi files, creates a memory graph of dependencies between them, and uses `dot` to display the graph into a pdf/image file.


Authors
-------

* Fabrice Le Fessant <fabrice.le_fessant@origin-labs.com>
