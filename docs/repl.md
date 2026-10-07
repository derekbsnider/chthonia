# The REPL

REPL stands for **Read–eval–print loop**. It reads one thing you type,
runs it, prints the result, and waits for the next. It is the quickest way
to find out what a piece of C does: no `main`, no saving, no compiling
step.

It sits at the bottom of the window. Click in it to type.

## What you can type

| You type | What happens |
|:--|:--|
| `int x = 6 * 7;` | declares `x`; later lines can use it |
| `x + 1` | prints `43`: an expression's value is shown |
| `printf("hi\n");` | runs the statement; `hi` appears |
| `int square(int n) { return n * n; }` | defines a function |
| `square(5)` | prints `25` |

Everything you define stays until the session ends, and the **Symbols**
view lists it.

Lines that start with `%` are commands for the REPL itself. Type `%help` to
see them all.

## Running a whole file

**F5** (**Run ▸ Run**) starts a fresh session, loads the file you are
editing (unsaved changes included) and runs its `main`. What the program
prints appears in the REPL, and when it asks for input you type it there.
When it finishes, its functions and variables are still in the REPL, ready
to try.

## When a program misbehaves

- **Run ▸ Stop** (Ctrl+F2) ends the session.
- **Run ▸ Interrupt** (Ctrl+C in the REPL, when no text is selected) stops
  what is running and returns to the prompt. Your names are kept.
- **Run ▸ Send EOF** (Ctrl+D in the REPL) tells a program that reads input
  that there is no more.

## Tidying up

**Edit ▸ Clear REPL** (Ctrl+L) clears what the REPL shows. Your names are
kept.
