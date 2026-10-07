# Building Chthonia from source

This page is for people who want to change Chthonia. To use it, see
[Installing Chthonia](install.md).

## What you need

- madc 0.102.0 or newer, installed (see [Installing](install.md)). madc is
  the compiler that builds Chthonia, and its IDE library, madcide, is what
  Chthonia is built on.
- `bash`, and on Linux `xvfb-run` for the window tests.

The scripts use the `madc` on your `PATH`. To use another one, set
`MADC=/path/to/madc`.

## The usual commands

```sh
scripts/build.sh                     # builds build/chthonia
scripts/run_tests.sh                 # the tests in tests/
xvfb-run scripts/run_tests.sh --gui  # the window tests in tests/gui/
```

## How the code is organised

| Path | What it is |
|:--|:--|
| `chthonia_main.mad` | The program: names the product and starts the IDE |
| `chthonia_version.h` | Chthonia's version and home page |
| `plugins/chthonia/` | Everything that makes Chthonia look and behave as it does |
| `plugins/chthonia/chthonia.layout` | Where each part of the window goes |
| `plugins/chthonia/chthonia.menu` | The menus and the toolbar |
| `plugins/chthonia/chthonia.mad` | The Symbols view |
| `plugins/chthonia/chthonia.help/` | The built-in Help pages (Markdown) |
| `tests/` | Tests, each a `.mad` program with the output it must print (`.expect`) |
| `scripts/` | Building, testing and packaging |

Most changes are to the files in `plugins/chthonia/`: they are plain text,
and the Help pages are ordinary Markdown.

## Packages

```sh
scripts/package_linux.sh           # .deb, .rpm and .tar.gz in dist/
scripts/package_windows.sh         # the Windows .zip (needs a Windows madc)
scripts/package_macos.sh           # the macOS .tar.gz (run on a Mac)
scripts/check_install.sh <prefix>  # checks an installed Chthonia
```

Each package is built against the madc that builds it and requires that
version or newer.

## Releases

Every push runs the tests on Linux, Windows and macOS. A tag `vX.Y.Z` that
matches `chthonia_version.h` also builds every package and drafts a release
with them.
