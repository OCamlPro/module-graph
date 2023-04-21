
[![Actions Status](https://github.com/ocamlpro/ocp-cmtdeps/workflows/Main%20Workflow/badge.svg)](https://github.com/ocamlpro/ocp-cmtdeps/actions)
[![Release](https://img.shields.io/github/release/ocamlpro/ocp-cmtdeps.svg)](https://github.com/ocamlpro/ocp-cmtdeps/releases)

# ocp-cmtdeps

The `ocp-cmtdeps` tool generates a graph of dependencies between OCaml
modules using compiled object files. `ocp-cmtdeps` scans the current
directory and sub-directories looking for `.cmt`/`.cmti`/`.cmi` files,
creates a memory graph of dependencies between them, and uses `dot` to
display the graph into a pdf/image file.

See examples of generated graphs at the end of this file.

## Installation

The `ocp-cmtdeps` binary should be built with the same version of OCaml
as the project you want to analyze with it.

The recommended way to install it is, within your project `opam` switch:

```
opam pin git+https://github.com/OCamlPro/ocp-cmtdeps
```

This command should ask you confirmation to create the packages
contained in the `ocp-cmtdeps` project, and then install it in the
switch.

You will also need to have `dot` installed on your computer: on
Debian/Ubuntu systems, it is part of the `graphviz` package.

## Usage

In your project, just run:

```
$ ocp-cmtdeps
Generated 23 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

By default, `ocp-cmtdeps` scans the current directory and its
sub-directories, looking for `.cmt/.cmti` files. It only ignores the
`_opam/` sub-directory.

You can specify another set of directories to scan:

```
$ ocp-cmtdeps _build/default/src/parsers
Generated 6 edges in "deps.dot" and "deps.pdf"
```

You can change the format of the generated file with `-T/--format
FORMAT`:

```
$ ocp-cmtdeps --format png
Generated 23 edges in "deps.dot" and "deps.png"
$ display deps.png
```

You can change the name of the generated file with `-o/--output
BASENAME`:

```
$ ocp-cmtdeps -o alt-ergo-deps
Generated 23 edges in "alt-ergo-deps.dot" and "alt-ergo-deps.pdf"
$ evince alt-ergo-deps.pdf
```

In some cases, `.cmt`/`.cmti` files are not available, so you may want
to use `.cmi` files with `--cmi`:

```
$ ocp-cmtdeps --cmi
Generated 21 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

By default, `ocp-cmtdeps` drops direct links between modules if these
links are implied by transitive dependencies. You can keep them with
`-A/--all-links`:

```
$ ocp-cmtdeps --all-links
Generated 32 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

If modules are packed/wrapped within a module (default behavior for
`dune`), you may use the `-R/--remove-pack MODNAME` to filter modules
(keeping only the ones within the pack) and remove the corresponding
prefix:

```
$ ocp-cmtdeps --remove-pack AltErgoLib
Generated 19 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

You can display the filenames in the grap instead of the module names
using the `--filenames` option:

```
$ ocp-cmtdeps --filename
Generated 23 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

You can filter out modules using a regexp with `-X/--ignore-module
REGEXP` where regexp is in the glob format:

```
$ ocp-cmtdeps -X 'AltErgoLib__*'
Generated 3 edges in "deps.dot" and "deps.pdf"
$ evince deps.pdf
```

## Examples

* Raw Dependencies for `ocp-cmtdeps`:
![](/docs/assets/images/ocp-cmtdeps-deps.png)

* All Dependencies for `ocp-cmtdeps` (`--all-links`):
![](/docs/assets/images/ocp-cmtdeps-deps-all.png)

* Curated Dependencies for `ocp-cmtdeps` (`--remove-pack `):
![](/docs/assets/images/ocp-cmtdeps-deps-all.png)

* Raw Dependencies for `alt-ergo`:
![](/docs/assets/images/alt-ergo-deps.png)

* Dependencies restricted to `AltErgoLib` for `alt-ergo` (`--remove-pack AltErgoLib`):
![](/docs/assets/images/alt-ergo-deps-pack.png)

## Resources

* Website: https://ocamlpro.github.io/ocp-cmtdeps
* General Documentation: https://ocamlpro.github.io/ocp-cmtdeps/sphinx
* API Documentation: https://ocamlpro.github.io/ocp-cmtdeps/doc
* Sources: https://github.com/ocamlpro/ocp-cmtdeps
