# Changelog

## [Unreleased]

## [v0.3.0] — 2026-10-23

- Chthonia is now built on madcide 0.9.0, which carries madc 0.106.0.
- On Windows, Chthonia now keeps your settings in your `%APPDATA%` folder,
  where Windows programs normally store them; before, it looked only in your
  home folder.
- When a project sits in a folder whose name has a dot in it, Chthonia now
  saves that project's layout under the project's own name — a project
  `proj.d/myproj` keeps its layout in `myproj.layout`, not a name cut short
  at the dot.
- To build Chthonia you now need madcide 0.9.0.

## [v0.2.0] — 2026-10-15

- Chthonia is now built on madcide 0.8.0, which carries madc 0.105.0.
- The REPL shows code in colour: a line `:%p` prints, a `%type` answer and
  each entry you type are coloured as `madc -i` colours them.
- `%runall` in the REPL runs the REPL buffer again in a fresh session, each
  entry with what it printed and its value.
- An edit to the REPL buffer takes effect at once: a changed function is
  redefined and a changed variable initialized again, and nothing else runs
  again.
- To build Chthonia you now need madcide 0.8.0.

## [v0.1.0] — 2026-10-11

- New colours: VS Code's Dark+ scheme, in the window and in a terminal.
- The editor numbers its lines and marks the line the caret is on.
- In a terminal, the menu bar sits on the top row and the status bar on
  the bottom one.
- Chthonia is now built on madcide 0.7.0, the editor in its own home
  (https://github.com/derekbsnider/madcide), which carries the madc compiler
  it is built with. (Chthonia had been built directly with madc.)
- The Symbols view — the session's functions and variables in the right
  sidebar — is now part of madcide itself. Chthonia's own plugin code is
  gone; its bundle is purely its look and feel: keys, layout, menus, help
  and colours.
- Each package now carries madcide and the madc it is built on, so there is
  still a single install and nothing else to set up.
- To build Chthonia you now need madcide 0.7.0 from madcide's releases page,
  rather than madc on its own; `MADCIDE_PACKAGE` names the release each
  package carries.

## [v0.0.3] — 2026-10-08

- Added autoindent, which can be toggled off and on.
- Built on madc 0.102.1 (many bug fixes).

## [v0.0.2] — 2026-10-07

- Each package now includes madc, so there is a single install and nothing else to set up.

## [v0.0.1] — 2026-10-07

- First release of Chthonia, an easy editor for learning C and C++.
- Withdrawn and replaced by v0.0.2.
