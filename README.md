
[![Actions Status](https://github.com/ocamlpro/module-graph/workflows/Main%20Workflow/badge.svg)](https://github.com/ocamlpro/module-graph/actions)
[![Release](https://img.shields.io/github/release/ocamlpro/module-graph.svg)](https://github.com/ocamlpro/module-graph/releases)

# module-graph

The `module-graph` tool generates a graph of dependencies between OCaml
modules using compiled object files. `module-graph` scans the current
directory and sub-directories looking for `.cmt`/`.cmti`/`.cmi` files,
creates a memory graph of dependencies between them, and uses `dot` to
display the graph into a pdf/image file.

See examples of generated graphs at the end of this file.

## Installation

The `module-graph` binary should be built with the same version of OCaml
as the project you want to analyze with it.

The recommended way to install it is, within your project `opam` switch:

```
opam pin git+https://github.com/OCamlPro/module-graph
```

This command should ask you confirmation to create the packages
contained in the `module-graph` project, and then install it in the
switch.

You will also need to have `dot` installed on your computer: on
Debian/Ubuntu systems, it is part of the `graphviz` package.

## Usage

In your project, just run:

```
$ module-graph
Generated 23 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

By default, `module-graph` scans the current directory and its
sub-directories, looking for `.cmt/.cmti` files. It only ignores the
`_opam/` sub-directory.

You can specify another set of directories to scan:

```
$ module-graph _build/default/src/parsers
Generated 6 edges in "deps.dot" and "deps.pdf"
```

You can change the format of the generated file with `-T/--format
FORMAT`:

```
$ module-graph --format png
Generated 23 edges in "deps.dot" and "deps.png"
$ display deps.png
```

You can change the name of the generated file with `-o/--output
BASENAME`:

```
$ module-graph -o alt-ergo-deps
Generated 23 edges in "alt-ergo-deps.dot" and "alt-ergo-deps.pdf"
$ evince alt-ergo-deps.pdf
```

In some cases, `.cmt`/`.cmti` files are not available, so you may want
to use `.cmi` files with `--cmi`:

```
$ module-graph --cmi
Generated 21 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

By default, `module-graph` drops direct links between modules if these
links are implied by transitive dependencies. You can keep them with
`-A/--all-links`:

```
$ module-graph --all-links
Generated 32 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

If modules are packed/wrapped within a module (default behavior for
`dune`), you may use the `-R/--remove-pack MODNAME` to filter modules
(keeping only the ones within the pack) and remove the corresponding
prefix:

```
$ module-graph --remove-pack AltErgoLib
Generated 19 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

You can display the filenames in the grap instead of the module names
using the `--filenames` option:

```
$ module-graph --filename
Generated 23 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

You can filter out modules using a regexp with `-X/--ignore-module
REGEXP` where regexp is in the glob format:

```
$ module-graph -X 'AltErgoLib__*'
Generated 3 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

## Examples

* Raw Dependencies for `module-graph`:
![](/docs/assets/images/module-graph-deps.png)

* All Dependencies for `module-graph` (`--all-links`):
![](/docs/assets/images/module-graph-deps-all.png)

* Raw Dependencies for `alt-ergo`:
![](/docs/assets/images/alt-ergo-deps.png)

* Dependencies restricted to `AltErgoLib` for `alt-ergo` (`--remove-pack AltErgoLib`):
![](/docs/assets/images/alt-ergo-deps-pack.png)

## Resources

* Website: https://ocamlpro.github.io/module-graph
* General Documentation: https://ocamlpro.github.io/module-graph/sphinx
* API Documentation: https://ocamlpro.github.io/module-graph/doc
* Sources: https://github.com/ocamlpro/module-graph
