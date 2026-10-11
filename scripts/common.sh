# common.sh — what Chthonia's scripts share; each sources it.
#
#   here    Chthonia's top directory
#   madc    MADC, the madc to use, as a command (default: madc on PATH;
#           "wine <madcide folder>/bin/madc.exe" for the Windows one) — the
#           madc a madcide release carries
#   exe     the executable suffix of madc's platform ("" or ".exe")
#   chthonia_setup
#           sets inc (madcide's public headers) and bundle (Chthonia's
#           bundle), both absolute, or says why it cannot
#   madcide_paired
#           MADCIDE_PACKAGE, the madcide release package Chthonia's packages
#           carry (madcide with the madc it is built on), as madcide_pkg and
#           its version madcide_ver, and the version of the madc building
#           Chthonia as madc_ver
#   madcide_unpack PACKAGE ROOT
#           a madcide release package unpacked into ROOT, madc's folder
#           layout with madcide in it, checked to carry the madc that builds
#           Chthonia
#   refresh_sums DIST FILE...
#           DIST/SHA256SUMS's lines for the packages just made
#   plain_modes DIR
#           DIR's tree with the modes a package installs
#   capped SECONDS COMMAND...
#           COMMAND under a wall-clock and a CPU limit
#
# madcide's public headers are MADCIDE_INCLUDE, else the install's beside
# madc: <prefix>/share/madcide/include (Linux, macOS), or the include
# directory beside madc.exe (Windows, where madcide's data sits beside the
# programs). Chthonia's bundle is plugins/chthonia, its plugin's directory.

here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
madc=${MADC:-madc}

# The madc program is the command's last word; one with a directory becomes
# absolute, since the scripts change directory.
madc_prog=${madc##* }
madc_pre=
[ "$madc_prog" != "$madc" ] && madc_pre="${madc% *} "
case "$madc_prog" in
/*|[A-Za-z]:*) ;;
*/*) madc_prog=$(cd "$(dirname "$madc_prog")" && pwd)/$(basename "$madc_prog")
     madc="$madc_pre$madc_prog" ;;
esac
exe=
case "$madc_prog" in
*.exe) exe=.exe ;;
esac

# The directory holding the madc program ("" = madc is not found).
madc_bindir() {
	local p=$madc_prog
	case "$p" in
	*/*) ;;
	*) p=$(command -v "$p") || return 0 ;;
	esac
	(cd "$(dirname "$p")" 2>/dev/null && pwd)
}

# madcide's installed data directory SUB beside madc: <prefix>/share/madcide/SUB,
# else <bindir>/SUB ("" = neither).
madcide_data() {
	local b
	b=$(madc_bindir)
	[ -n "$b" ] || return 0
	if [ -d "$b/../share/madcide/$1" ]; then
		(cd "$b/../share/madcide/$1" && pwd)
	elif [ -d "$b/$1" ]; then
		echo "$b/$1"
	fi
}

chthonia_setup() {
	inc=${MADCIDE_INCLUDE:-}
	[ -n "$inc" ] || inc=$(madcide_data include)
	if [ -z "$inc" ]; then
		echo "$(basename "$0"): no madcide headers beside madc ($madc) — set MADC or MADCIDE_INCLUDE" >&2
		return 1
	fi
	if ! inc=$(cd "$inc" 2>/dev/null && pwd) || [ ! -f "$inc/madcide/harness" ]; then
		echo "$(basename "$0"): no <madcide/harness> in ${MADCIDE_INCLUDE:-$inc} — set MADCIDE_INCLUDE" >&2
		return 1
	fi
	bundle=$here/plugins/chthonia
	if [ ! -f "$bundle/chthonia.plugin" ]; then
		echo "$(basename "$0"): no chthonia.plugin in $bundle" >&2
		return 1
	fi
}

# refresh_sums DIST FILE... — DIST/SHA256SUMS gets these files' lines and
# keeps every other package's (each platform packages on its own host).
refresh_sums() {
	(
		cd "$1" || exit 1
		shift
		touch SHA256SUMS
		for f in "$@"; do
			awk -v f="$f" '$2 != f' SHA256SUMS > SHA256SUMS.tmp
			mv SHA256SUMS.tmp SHA256SUMS
		done
		if command -v sha256sum > /dev/null; then
			sha256sum "$@" >> SHA256SUMS
		else
			shasum -a 256 "$@" >> SHA256SUMS
		fi
	)
}

# madcide_paired — MADCIDE_PACKAGE, the madcide release package every
# Chthonia package carries (its .zip, .tar.gz or .deb: madcide with the madc
# release it is built on), as madcide_pkg (absolute) and its version as
# madcide_ver, and the version of the madc building Chthonia as madc_ver:
# chthonia links the libraries the package ships, so madcide_unpack checks
# the package's madc is that one.
madcide_paired() {
	madcide_pkg=${MADCIDE_PACKAGE:-}
	if [ -z "$madcide_pkg" ] || [ ! -f "$madcide_pkg" ]; then
		echo "$(basename "$0"): MADCIDE_PACKAGE names no madcide release package ('$madcide_pkg'): Chthonia's packages carry madcide and its madc" >&2
		return 1
	fi
	madcide_pkg=$(cd "$(dirname "$madcide_pkg")" && pwd)/$(basename "$madcide_pkg")
	madcide_ver=$(basename "$madcide_pkg" | sed -n 's/^madcide[-_]\([0-9]*\.[0-9]*\.[0-9]*\)[-_.].*/\1/p')
	if [ -z "$madcide_ver" ]; then
		echo "$(basename "$0"): MADCIDE_PACKAGE ($madcide_pkg) is not named as a madcide release package" >&2
		return 1
	fi
	# shellcheck disable=SC2086
	madc_ver=$($madc --version | sed -n 's/^madc \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' | head -1)
	if [ -z "$madc_ver" ]; then
		echo "$(basename "$0"): the madc building Chthonia ($madc) names no version" >&2
		return 1
	fi
}

# madcide_unpack PACKAGE ROOT — a madcide release package unpacked into
# ROOT: madc's folder layout (bin/, lib/, share/, the notices) with madcide
# in it, the layout madcide's zip and tarballs have and its .deb installs in
# usr/lib/madcide/. Its bin/madc must be the madc building Chthonia
# (madc_ver, from madcide_paired).
madcide_unpack() {
	local pkg=$1 root=$2 t top v
	t=$(mktemp -d)
	case "$pkg" in
	*.zip) unzip -q "$pkg" -d "$t/x" ;;
	*.tar.gz) mkdir "$t/x" && tar -xzf "$pkg" -C "$t/x" ;;
	*.deb) dpkg-deb -x "$pkg" "$t/deb" ;;
	*) echo "madcide_unpack: $pkg is not a madcide release package (.zip, .tar.gz, .deb)" >&2
	   rm -rf "$t"; return 1 ;;
	esac
	mkdir -p "$root"
	if [ -d "$t/deb" ]; then
		if [ ! -d "$t/deb/usr/lib/madcide" ]; then
			echo "madcide_unpack: $pkg holds no usr/lib/madcide" >&2
			rm -rf "$t"; return 1
		fi
		cp -R "$t/deb/usr/lib/madcide/." "$root/"
	else
		top=$(ls -A "$t/x")
		if [ "$(printf '%s\n' "$top" | wc -l | tr -d ' ')" != 1 ] || [ ! -d "$t/x/$top" ]; then
			echo "madcide_unpack: $pkg does not hold one folder" >&2
			rm -rf "$t"; return 1
		fi
		cp -R "$t/x/$top/." "$root/"
	fi
	rm -rf "$t"
	if [ ! -f "$root/bin/madc$exe" ] || [ ! -f "$root/bin/madcide$exe" ]; then
		echo "madcide_unpack: $pkg holds no bin/madc$exe and bin/madcide$exe" >&2
		return 1
	fi
	# shellcheck disable=SC2086
	v=$($madc_pre"$root/bin/madc$exe" --version | sed -n 's/^madc \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' | head -1)
	if [ "$v" != "$madc_ver" ]; then
		echo "madcide_unpack: $pkg carries madc '$v', the madc building Chthonia ($madc) is '$madc_ver'" >&2
		return 1
	fi
}

# plain_modes DIR — directories 0755 (a setgid bit inherited from the
# checkout cleared first, since a numeric mode keeps it), executables 0755,
# every other file 0644: what a package installs, whatever the checkout's
# modes and umask were.
plain_modes() {
	find "$1" -type d -exec chmod g-s {} +
	find "$1" -type d -exec chmod 0755 {} +
	find "$1" -type f -perm -0100 -exec chmod 0755 {} +
	find "$1" -type f ! -perm -0100 -exec chmod 0644 {} +
}

# capped SECONDS COMMAND... — COMMAND under a wall-clock limit (coreutils'
# timeout; gtimeout where Homebrew's coreutils provides it, as on a Mac) and
# the same CPU limit where the shell can set one (Git Bash on Windows cannot),
# so a hang fails instead of running on.
tmo=$(command -v timeout || command -v gtimeout || true)
capped() {
	if [ -z "$tmo" ]; then
		echo "$(basename "$0"): no timeout command (coreutils: timeout, or gtimeout on a Mac)" >&2
		return 124
	fi
	local s=$1
	shift
	(ulimit -t "$s" 2> /dev/null || true; "$tmo" "$s" "$@")
}
