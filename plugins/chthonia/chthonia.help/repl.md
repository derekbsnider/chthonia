# The REPL

The REPL (**View ▸ REPL**) is a Read–eval–print loop: it reads one
entry at a time — a declaration, a statement or an expression — runs
it, and prints an expression's value.

| Entry | What it does |
|:--|:--|
| `int x = 6 * 7;` | declares `x`, which later entries can use |
| `x + 1` | prints `43` |
| `%help` | lists the REPL's commands |

Entries that start with `%` are the REPL's own commands; `%help` lists
them all.

**Edit ▸ Clear REPL** clears what the REPL shows; the session's names
stay.

See also: [Running a program](running.md).
