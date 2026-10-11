# Changelog

## [Unreleased]

## [v0.1.0] — 2026-10-11

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
