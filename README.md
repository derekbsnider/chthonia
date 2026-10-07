# Chthonia

**An easy place to learn C and C++.**

Chthonia is a small, friendly code editor for beginners. Write a program
at the top, press **F5**, and see what it prints at the bottom. Or skip the
program entirely: type one line of C into the REPL and see its value right
away.

<!-- A screenshot goes here: docs/images/chthonia.png -->

Chthonia runs on [madc](https://github.com/derekbsnider/madc), so there is
no separate compiler to install and nothing to configure.

## What you can do

- **Write** C, C++ or madc in an editor with syntax colours, find and
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

Install madc first, then Chthonia. Chthonia needs madc 0.102.0 or newer.

| Your computer | Download | Then |
|:--|:--|:--|
| Ubuntu 24.04 or 22.04 (also in WSL) | madc's and Chthonia's `.deb` for your Ubuntu version | `sudo apt install ./madc_*.deb ./chthonia_*.deb` |
| Windows 10 or 11 | madc's and Chthonia's `.zip` | Unzip madc, unzip Chthonia into the madc folder, run `bin\chthonia.exe` |
| macOS (Apple silicon or Intel) | madc's and Chthonia's `.tar.gz` for your Mac | Unpack madc, unpack Chthonia into the madc folder, run `bin/chthonia` |

Chthonia's packages are on its
[releases page](https://github.com/derekbsnider/chthonia/releases); madc's
are on [madc's](https://github.com/derekbsnider/madc/releases). Step-by-step
instructions: [Installing Chthonia](docs/install.md).

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
- [Building Chthonia from source](docs/building.md), for contributors

## License

Chthonia is free software under the
[Mozilla Public License 2.0](LICENSE).
