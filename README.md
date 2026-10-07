# Chthonia

**An easy place to learn C and C++.**

Chthonia is a small, friendly code editor for beginners. Write a program
at the top, press **F5**, and see what it prints at the bottom. Or skip the
program entirely: type one line of C into the REPL and see its value right
away.

<!-- A screenshot goes here: docs/images/chthonia.png -->

Everything it needs comes in one download: there is no separate compiler
to install and nothing to configure.

## What you can do

- **Write** C or C++ in an editor with syntax colours, find and
  replace, undo, and tabs for your open files.
- **Try things out** in the REPL, a *Read–eval–print loop*: type
  `int x = 6 * 7;`, then `x + 1`, and it prints `43`.
- **Run** the whole file with **F5**. Its output appears in the REPL, and
  you type its input there too.
- **See your names**: the Symbols view lists the functions and variables
  you have defined.
- **Find mistakes**: saving checks the file and lists any problems; click
  one to jump to its line.
- **Get help** without leaving: **Help ▸ Help Contents** opens beside your
  files.

## Install

One download, one install: each package has everything Chthonia needs.

| Your computer | Download | Then |
|:--|:--|:--|
| Ubuntu 24.04 or 22.04 (also in WSL) | Chthonia's `.deb` for your Ubuntu version | `sudo apt install ./chthonia_*.deb` |
| Fedora | Chthonia's `.rpm` | `sudo dnf install ./chthonia-*.rpm` |
| Windows 10 or 11 | Chthonia's `.zip` | Unzip it, run `bin\chthonia.exe` in its folder |
| macOS (Apple silicon or Intel) | Chthonia's `.tar.gz` for your Mac | Unpack it, run `bin/chthonia` in its folder |

Download from the
[releases page](https://github.com/derekbsnider/chthonia/releases).
Step-by-step instructions: [Installing Chthonia](docs/install.md).

## Your first program

1. Start Chthonia.
2. **File ▸ New**, and type:

   ```c
   #include <stdio.h>

   int main(void)
   {
       printf("Hello!\n");
       return 0;
   }
   ```

3. **File ▸ Save** it as `hello.c`.
4. Press **F5**. `Hello!` appears in the REPL.

Then try the REPL: click in it, type `2 + 2` and press Enter.

More in [Getting started](docs/getting-started.md).

## Documentation

- [Installing Chthonia](docs/install.md)
- [Getting started](docs/getting-started.md): a tour of the window
- [The REPL](docs/repl.md)
- [Keyboard shortcuts](docs/keyboard.md)
- [Building Chthonia from source](docs/building.md), for contributors: it
  is built with [madc](https://github.com/derekbsnider/madc)

## License

Chthonia is free software under the
[Mozilla Public License 2.0](LICENSE).
