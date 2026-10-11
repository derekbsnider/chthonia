#!/bin/bash
# package_macos.sh — Chthonia's macOS tarball, standing alone:
#
#   chthonia-<ver>-macos-<arch>.tar.gz   one folder, chthonia-<ver>-macos-
#                                        <arch>/: the madcide release it is
#                                        built on (madcide's tarball, which
#                                        carries its madc) and Chthonia in it.
#                                        Unpack it, run bin/chthonia.
#
#   scripts/package_macos.sh [-o DIST]
#
#   MADC, MADCIDE_INCLUDE            as build.sh and stage.sh
#   MADCIDE_PACKAGE                  that madcide's release tarball, which
#                                    the tarball carries
#   -o DIST                          where the tarball goes (default dist/),
#                                    its line in its SHA256SUMS
#
# Run on a Mac of the architecture it packages: chthonia is AOT-compiled by
# the madc there. The version is chthonia_version.h's;
# the tarball is checked to hold exactly the staged files.
set -eu
. "$(dirname "$0")/common.sh"
dist=$here/dist
while [ $# -gt 0 ]; do
	case "$1" in
	-o) dist=$2; shift 2 ;;
	*) echo "usage: $0 [-o DIST]" >&2; exit 2 ;;
	esac
done
if [ "$(uname -s)" != Darwin ]; then
	echo "package_macos.sh: run it on a Mac (chthonia is AOT-compiled by the madc there)" >&2
	exit 1
fi
ver=$(sed -n 's/^#define CHTHONIA_VERSION "\(.*\)"$/\1/p' "$here/chthonia_version.h")
[ -n "$ver" ] || { echo "package_macos.sh: no CHTHONIA_VERSION in chthonia_version.h" >&2; exit 1; }
madcide_paired || exit 1

work=$here/tmp/package-macos
rm -rf "$work"
mkdir -p "$work" "$dist"
dist=$(cd "$dist" && pwd)
bash "$here/scripts/build.sh" -o "$work/chthonia"
folder=chthonia-$ver-macos-$(uname -m)
madcide_unpack "$madcide_pkg" "$work/tar/$folder"
CHTHONIA="$work/chthonia" bash "$here/scripts/stage.sh" macos "$work/tar/$folder"
plain_modes "$work/tar"
tgz=$folder.tar.gz
tar -C "$work/tar" -czf "$dist/$tgz" "$folder"
if ! diff <(tar -tzf "$dist/$tgz" | grep -v '/$' | LC_ALL=C sort) \
	  <(cd "$work/tar" && find . ! -type d | sed 's|^\./||' | LC_ALL=C sort) > "$work/diff"; then
	echo "package_macos.sh: $tgz does not hold exactly the staged files:" >&2
	cat "$work/diff" >&2
	exit 1
fi
refresh_sums "$dist" "$tgz"
echo "package_macos.sh: $dist/$tgz (madcide $madcide_ver, madc $madc_ver)"
