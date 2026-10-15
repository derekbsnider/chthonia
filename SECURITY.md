# Security Policy

## Supported versions

Security fixes land in the next release; only the latest release is
supported.

| Version          | Supported |
|------------------|-----------|
| latest release   | yes       |
| earlier releases | no        |

## Reporting a vulnerability

Please report a vulnerability privately, not in a public issue:

1. Open the repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Describe the problem: the Chthonia version (Help ▸ About), the
   platform, and the steps that show it.

A confirmed vulnerability is fixed in the next release, and the release
notes credit the reporter unless they ask otherwise.

## Scope

Chthonia runs the programs you write, with your rights; that is what it
is for, so it is not a vulnerability in itself.

In scope:

- opening or editing a file running code you did not ask to run;
- an installed package (`.deb`, `.rpm`, tarball, zip) that installs files
  with unsafe permissions or outside the places it names.

Chthonia is built on madcide, which carries the madc compiler. A flaw in
either belongs in its own repository:
[madcide](https://github.com/derekbsnider/madcide) or
[madc](https://github.com/derekbsnider/madc).
