# Getting started

## The window

```
┌──────────────────────────────────────────┬──────────────┐
│ New  Open  Save  │  Run  Stop            │   Symbols    │
├──────────────────────────────────────────┤              │
│ hello.c │ Help                           │              │
│                                          │ count int 3  │
│   your program                           │ main int ()  │
│                                          │              │
├──────────────────────────────────────────┤              │
│ REPL │ Problems │ Output │ Terminal      │              │
│ madc> x + 1                              │              │
│ 43                                       │              │
└──────────────────────────────────────────┴──────────────┘
```

- **The editor** (top) holds your files. Each open file has a tab; Help
  opens as a tab here too.
- **The REPL** (bottom) is where your program's output appears, and where
  you can type C one line at a time. Beside it are **Problems** (what is
  wrong with the file), **Output** (a build's messages) and **Terminal**
  (a program a build runs).
- **Symbols** (right) lists the names your code has defined: functions,
  with their types, and variables, with their values. **Outline**, its
  second tab, lists the definitions in the file you are editing.
- **The toolbar** has New, Open and Save, then **Run** and **Stop**.

## Your first program

1. **File ▸ New** opens an empty file.
2. Type:

   ```c
   #include <stdio.h>

   int main(void)
   {
       printf("Hello!\n");
       return 0;
   }
   ```

3. **File ▸ Save** and name it `hello.c`. The ending tells Chthonia the
   language: `.c` for C, `.cpp` for C++, `.mad` for madc.
4. Press **F5** (or **Run** on the toolbar). `Hello!` appears in the REPL.

## Try the REPL

After a run, your program's names are still there. Click in the REPL and
type:

```
madc> int count = 3;
madc> count * 2
6
```

`count` now shows up in **Symbols**. Read more in [The REPL](repl.md).

## When something is wrong

Saving checks your file. If it finds mistakes, they are listed in
**View ▸ Problems**; click one to jump to its line. A program that runs
forever can be stopped with **Stop** (Ctrl+F2).

## Where to go next

- **Help ▸ Help Contents** is built in and opens beside your files.
- **Help ▸ Keyboard Help** lists every key; see also
  [Keyboard shortcuts](keyboard.md).
- **Run ▸ Language…** chooses which C or C++ standard your programs are
  compiled as.
- **Tools ▸ Options…** holds Chthonia's settings.
