#!/bin/bash
# package_windows.sh — Chthonia's Windows zip, standing alone:
#
#   chthonia-<ver>-windows-x86_64.zip   one folder, chthonia-<ver>-windows-
#                                       x86_64\: the madc release it is paired
#                                       with (madc's zip) and Chthonia in it —
#                                       chthonia.exe beside madc.exe, where it
#                                       binds libmadc-0.dll and madcide.dll,
#                                       its bundle beside madcide's shipped
#                                       plugins. Unzip it, run bin\chthonia.exe.
#
#   scripts/package_windows.sh [-o DIST]
#
#   MADC          the Windows madc, as a command: "wine <madc folder>/bin/madc.exe"
#                 on Linux, <madc folder>/bin/madc.exe on Windows
#   MADC_PACKAGE  that madc's release zip, which the zip carries
#   MADCIDE_INCLUDE, MADCIDE   as build.sh and stage.sh
#   -o DIST       where the zip goes (default dist/), its line in its SHA256SUMS
#
# The version is chthonia_version.h's. The zip is checked to hold exactly
# the staged files.
set -eu
. "$(dirname "$0")/common.sh"
dist=$here/dist
while [ $# -gt 0 ]; do
	case "$1" in
	-o) dist=$2; shift 2 ;;
	*) echo "usage: $0 [-o DIST]" >&2; exit 2 ;;
	esac
done
if [ "$exe" != .exe ]; then
	echo "package_windows.sh: MADC ($madc) is not a Windows madc (madc.exe)" >&2
	exit 1
fi
ver=$(sed -n 's/^#define CHTHONIA_VERSION "\(.*\)"$/\1/p' "$here/chthonia_version.h")
[ -n "$ver" ] || { echo "package_windows.sh: no CHTHONIA_VERSION in chthonia_version.h" >&2; exit 1; }
madc_paired || exit 1

work=$here/tmp/package-windows
rm -rf "$work"
mkdir -p "$work" "$dist"
dist=$(cd "$dist" && pwd)
bash "$here/scripts/build.sh" -o "$work/chthonia.exe"
folder=chthonia-$ver-windows-x86_64
madc_unpack "$madc_pkg" "$work/zip/$folder"
CHTHONIA="$work/chthonia.exe" bash "$here/scripts/stage.sh" windows "$work/zip/$folder"
plain_modes "$work/zip"
zipname=$folder.zip
rm -f "$dist/$zipname"
(cd "$work/zip" && zip -q -r -X "$dist/$zipname" "$folder")
if ! diff <(unzip -Z1 "$dist/$zipname" | grep -v '/$' | LC_ALL=C sort) \
	  <(cd "$work/zip" && find . ! -type d | sed 's|^\./||' | LC_ALL=C sort) > "$work/diff"; then
	echo "package_windows.sh: $zipname does not hold exactly the staged files:" >&2
	cat "$work/diff" >&2
	exit 1
fi
refresh_sums "$dist" "$zipname"
echo "package_windows.sh: $dist/$zipname (madc $madc_ver)"
