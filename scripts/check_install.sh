#!/bin/bash
# check_install.sh — Chthonia installed, standing alone, run as a user runs
# it (Linux, macOS, Windows).
#
#   scripts/check_install.sh PREFIX [SYSTEM]
#
#   PREFIX  the installation: the folder holding bin/chthonia — a tarball's
#           or the zip's folder, or /usr/lib/chthonia where a .deb or .rpm
#           installs it. madcide's data is under share/madcide, or beside
#           the programs in bin\ on Windows (bin/chthonia.exe).
#   SYSTEM  where its desktop entry and icons are (default PREFIX; /usr, or
#           a package root's usr/, for a .deb or .rpm)
#
# Each probe runs from a directory of its own with no user configuration
# and no library path, and each control must fail:
#   0. the installation carries its madc: bin/madc runs, and on Linux
#      chthonia loads libmadc from PREFIX/lib;
#   1. chthonia prints its usage line;
#   2. `-c check` over a C file that includes <stdio.h> is clean: madc's
#      installed headers and engine serve it [control: a syntax error is 1
#      problem, exit status 1];
#   3. its bundle is the installed one: its menu bar has no Window menu
#      [control: the bundle hidden, chthonia runs the default profile, whose
#      Window menu is listed]; so it is when started inside a madc source
#      tree (a tools/madcide/ with plugins and profiles of its own): an
#      installed program reads its installation's data;
#   4. Tools ▸ Key bindings… is on its Tools menu and lists madcide's six key
#      styles [control: madcide's profiles hidden, it lists none];
#   5. on Linux, its desktop entry and its 256 px icon are installed.
set -u
. "$(dirname "$0")/common.sh"
if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	echo "usage: $0 PREFIX [SYSTEM]" >&2
	exit 2
fi
prefix=$(cd "$1" && pwd)
system=$(cd "${2:-$1}" && pwd)
if [ -f "$prefix/bin/chthonia.exe" ]; then
	sfx=.exe data=$prefix/bin linux=0
else
	sfx= data=$prefix/share/madcide linux=1
	[ "$(uname -s)" = Darwin ] && linux=0
fi
chthonia=$prefix/bin/chthonia$sfx
bundle=$data/plugins/chthonia
profiles=$data/profiles
work=$(mktemp -d)
hidden=
restore() {
	[ -n "$hidden" ] && [ -e "$hidden.hidden" ] && mv "$hidden.hidden" "$hidden"
	rm -rf "$work"
}
trap restore EXIT
ok() { echo "check_install: ok — $1"; }
fail() { echo "check_install: FAIL — $1" >&2; exit 1; }
# run_in DIR ARG... — chthonia from DIR, no user configuration; output and
# status. run ARG... — the same from $work.
run_in() {
	local d=$1
	shift
	(cd "$d" && capped 60 env -u MADCIDE_PLUGIN_PATH -u LD_LIBRARY_PATH \
		-u DYLD_LIBRARY_PATH "MADCIDE_CONFIG_DIR=$work/no-config" \
		"$chthonia" "$@") 2>&1
}
run() { run_in "$work" "$@"; }
hide() { hidden=$1; mv "$1" "$1.hidden"; }
unhide() { mv "$hidden.hidden" "$hidden"; hidden=; }
[ -x "$chthonia" ] || fail "no executable $chthonia"
[ -f "$bundle/chthonia.plugin" ] || fail "no bundle in $bundle"

# 0. its own madc
out=$(cd "$work" && capped 60 env -u LD_LIBRARY_PATH -u DYLD_LIBRARY_PATH "$prefix/bin/madc$sfx" --version 2>&1)
case "$out" in
"madc "[0-9]*) ok "the installation carries its madc (${out%%$'\n'*})" ;;
*) fail "no madc of its own in $prefix/bin (got: $out)" ;;
esac
if [ "$linux" = 1 ]; then
	# ldd names it as found: <prefix>/bin/../lib/... through $ORIGIN.
	lib=$(env -u LD_LIBRARY_PATH ldd "$chthonia" | awk '$1 == "libmadc.so.0" { print $3 }')
	libdir=$(cd "$(dirname "${lib:-/nonexistent/x}")" 2>/dev/null && pwd)
	[ "$libdir" = "$prefix/lib" ] || fail "chthonia loads libmadc from '$lib', not $prefix/lib"
	ok "chthonia loads libmadc from its installation ($libdir)"
fi

# 1. usage
out=$(run --help)
case "$out" in
*"usage: chthonia"*) ok "chthonia prints its usage line" ;;
*) fail "chthonia --help printed no usage line (got: $out)" ;;
esac

# 2. -c check
printf '#include <stdio.h>\nint main(void) { printf("%%d\\n", 5); return 0; }\n' > "$work/ok.c"
printf '#include <stdio.h>\nint main(void) { return 0 }\n' > "$work/bad.c"
out=$(run ok.c -c check)
rc=$?
case "$rc:$out" in
0:*Problems*) ok "-c check over <stdio.h> is clean (exit status 0)" ;;
*) fail "-c check over <stdio.h> was not clean (exit status $rc: $out)" ;;
esac
out=$(run bad.c -c check)
rc=$?
case "$rc:$out" in
1:*"1 problem"*) ok "control: a syntax error is 1 problem (exit status 1)" ;;
*) fail "control broken: -c check over a syntax error (exit status $rc: $out)" ;;
esac

# 3. the installed bundle
out=$(run ok.c -c "menushow Window")
case "$out" in
*"No menu 'Window'."*) ok "the installed bundle's menu bar has no Window menu" ;;
*) fail "the menu bar has a Window menu: not the installed bundle's (got: $out)" ;;
esac
hide "$bundle"
out=$(run ok.c -c "menushow Window")
unhide
case "$out" in
*"No menu 'Window'."*) fail "control broken: the bundle hidden, the menu bar still has no Window menu" ;;
*"Split Window"*) ok "control: the bundle hidden, the default profile's Window menu is listed" ;;
*) fail "control broken: the bundle hidden, no Window menu either (got: $out)" ;;
esac
# A madc checkout's tools/madcide/ holds the default bundle and the key
# styles, never Chthonia's: copies of the installed ones stand in for them.
mkdir -p "$work/tree/tools/madcide/plugins"
cp -R "$data/plugins/default" "$work/tree/tools/madcide/plugins/"
cp -R "$profiles" "$work/tree/tools/madcide/profiles"
out=$(run_in "$work/tree" ../ok.c -c "menushow Help")
case "$out" in
*"About Chthonia"*) ok "started inside a madc source tree, the bundle is still the installed one" ;;
*) fail "started inside a madc source tree, Help has no About Chthonia: not the installed bundle (got: $out)" ;;
esac

# 4. key styles
styles=("Chthonia" "VS Code" "Vim" "Emacs" "JOE" "Pico")
out=$(run ok.c -c "menushow Tools")
case "$out" in
*"Key bindings"*) ok "the Tools menu has Key bindings…" ;;
*) fail "the Tools menu has no Key bindings… row (got: $out)" ;;
esac
out=$(run ok.c -c keystyle)
missing=
for s in "${styles[@]}"; do
	case "$out" in *". $s"*) ;; *) missing="$missing [$s]" ;; esac
done
[ -z "$missing" ] || fail "the Key bindings list lacks$missing (got: $out)"
ok "the Key bindings list names all ${#styles[@]} styles"
hide "$profiles"
out=$(run ok.c -c keystyle)
unhide
named=
for s in "${styles[@]}"; do
	case "$out" in *". $s"*) named="$named [$s]" ;; esac
done
[ -z "$named" ] || fail "control broken: the profiles hidden, the list still names$named"
ok "control: the profiles hidden, the Key bindings list names no style"

# 5. the desktop entry and icon
if [ "$linux" = 1 ]; then
	[ -f "$system/share/applications/chthonia.desktop" ] || fail "no $system/share/applications/chthonia.desktop"
	[ -f "$system/share/icons/hicolor/256x256/apps/chthonia.png" ] || fail "no $system/share/icons/hicolor/256x256/apps/chthonia.png"
	ok "the desktop entry and the 256 px icon are installed"
fi
echo "check_install: PASS ($prefix)"
