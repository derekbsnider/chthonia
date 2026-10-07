#!/bin/bash
# package_linux.sh — Chthonia's Linux packages, each standing alone: each
# carries the madc release it is paired with, so one package is the whole
# install.
#
#   chthonia_<ver>-<rel>_<arch>.deb       install Chthonia and its madc in
#   chthonia-<ver>-<rel>.<arch>.rpm       /usr/lib/chthonia/ (madc's folder
#                                         layout), with /usr/bin/chthonia, the
#                                         desktop entry and the icons under
#                                         /usr; no madc package needed, none
#                                         disturbed
#   chthonia-<ver>-linux-<arch>.tar.gz    one folder, chthonia-<ver>-linux-
#                                         <arch>/: madc's tarball with
#                                         Chthonia in it. Unpack it, run
#                                         bin/chthonia.
#
#   scripts/package_linux.sh [--deb] [-o DIST]
#
#   MADC, MADCIDE_INCLUDE, MADCIDE   as build.sh and stage.sh
#   MADC_PACKAGE                     that madc's release package, which the
#                                    packages carry: its tarball, or for
#                                    --deb the .deb of this Ubuntu release
#   PKG_RELEASE                      the package revision (default 1)
#   --deb                            the .deb alone (another Ubuntu release's)
#   -o DIST                          where the packages go (default dist/),
#                                    their lines in its SHA256SUMS
#
# The version is chthonia_version.h's. A window is Chthonia's default, so
# the packages require the WebKitGTK 6.0 and GTK 4 libraries madc's GUI
# module binds, and what every program and library they carry links. Each
# package is checked to hold exactly the staged files, each readable by
# every user.
#
# One .deb per Ubuntu release, built on it with that release's madc: on
# Ubuntu the revision is <rel>~ubuntu<VERSION_ID>, as madc's is, and the
# Depends is what the binaries link at this host's versions
# (dpkg-shlibdeps), so a package built for a newer release never installs
# on an older one.
set -eu
. "$(dirname "$0")/common.sh"
dist=$here/dist
deb_only=0
while [ $# -gt 0 ]; do
	case "$1" in
	--deb) deb_only=1; shift ;;
	-o) dist=$2; shift 2 ;;
	*) echo "usage: $0 [--deb] [-o DIST]" >&2; exit 2 ;;
	esac
done
ver=$(sed -n 's/^#define CHTHONIA_VERSION "\(.*\)"$/\1/p' "$here/chthonia_version.h")
rel=${PKG_RELEASE:-1}
debrel=$rel
apparmor=0
if [ "$( (. /etc/os-release 2>/dev/null; echo "${ID:-}") )" = ubuntu ]; then
	osver=$( (. /etc/os-release; echo "$VERSION_ID") )
	debrel="$rel~ubuntu$osver"
	# Ubuntu 24.04 and later deny an unprofiled program the user
	# namespaces the window's WebKit sandbox (bwrap) needs, and the
	# window dies at its first page (LP: #2046844). There the .deb
	# carries an AppArmor profile naming the program.
	if dpkg --compare-versions "$osver" ge 24.04; then
		apparmor=1
	fi
fi
if [ -z "$ver" ]; then
	echo "package_linux.sh: no CHTHONIA_VERSION in chthonia_version.h" >&2
	exit 1
fi
madc_paired || exit 1
case "$(uname -m)" in
x86_64) deb_arch=amd64; rpm_arch=x86_64 ;;
aarch64) deb_arch=arm64; rpm_arch=aarch64 ;;
*) echo "package_linux.sh: no package architecture for $(uname -m)" >&2; exit 1 ;;
esac
maint="Derek Snider <coding@psychedeliccanada.ca>"
home=$(sed -n 's/^#define CHTHONIA_HOME_PAGE "\(.*\)"$/\1/p' "$here/chthonia_version.h")
summary="An easy IDE to learn C and C++"
desc="Chthonia is a window to learn C and C++ in: the editor, the REPL
below it to try code in, and the Symbols view beside it, Run and Stop on
the toolbar. It is built on madc's IDE, madcide, and runs on madc's engine."

work=$here/tmp/package-linux
rm -rf "$work"
mkdir -p "$work" "$dist"
dist=$(cd "$dist" && pwd)
bash "$here/scripts/build.sh" -o "$work/chthonia"
strip --strip-unneeded "$work/chthonia"
# stage ROOT — the paired madc's folder with Chthonia in it.
stage() {
	madc_unpack "$madc_pkg" "$1"
	CHTHONIA="$work/chthonia" bash "$here/scripts/stage.sh" linux "$1"
}
# stage_system USR — a package's usr/: the folder in lib/chthonia/, and what
# the system reads in its own places — the program on PATH, the desktop
# entry, the icons, Chthonia's copyright.
stage_system() {
	local usr=$1 priv=$1/lib/chthonia
	stage "$priv"
	mkdir -p "$usr/bin" "$usr/share/doc"
	ln -s ../lib/chthonia/bin/chthonia "$usr/bin/chthonia"
	mv "$priv/share/applications" "$priv/share/icons" "$usr/share/"
	mv "$priv/share/doc/chthonia" "$usr/share/doc/"
}
# The staged entries of PREFIX (files and links), one path per line,
# relative to it.
staged() {
	(cd "$1" && find . ! -type d | sed 's|^\./||' | LC_ALL=C sort)
}
# check NAME LISTING STAGE — the package holds exactly the staged files.
check() {
	if ! diff <(LC_ALL=C sort <<< "$2") <(staged "$3") > "$work/diff"; then
		echo "package_linux.sh: $1 does not hold exactly the staged files:" >&2
		cat "$work/diff" >&2
		exit 1
	fi
}
# check_modes NAME LONG-LISTING — every entry is a 0755 directory or
# executable, a 0644 file (readable by every user), or a link.
check_modes() {
	local bad
	bad=$(awk '$1 !~ /^(drwxr-xr-x|-rwxr-xr-x|-rw-r--r--|lrwxrwxrwx)$/' <<< "$2")
	if [ -n "$bad" ]; then
		echo "package_linux.sh: $1 installs entries with other modes:" >&2
		echo "$bad" >&2
		exit 1
	fi
}

# ---- deb ----
debroot=$work/deb
stage_system "$debroot/usr"
mkdir -p "$debroot/DEBIAN"
# What every program and library the package carries links, at this host's
# versions; the carried libraries (libmadc, libmadcide, ...) resolve among
# themselves (-l).
priv=$debroot/usr/lib/chthonia
elves=()
while IFS= read -r f; do
	[ "$(head -c 4 "$f" | od -An -c | tr -d ' ')" = '177ELF' ] && elves+=("$f")
done < <(find "$priv" -type f)
mkdir -p "$work/shlibdeps/debian"
printf 'Source: chthonia\n\nPackage: chthonia\nArchitecture: any\n' > "$work/shlibdeps/debian/control"
shlibs=$(cd "$work/shlibdeps" && dpkg-shlibdeps -O --ignore-missing-info \
		-l"$priv/lib" "${elves[@]}" 2> shlibdeps.log |
	sed -n 's/^shlibs:Depends=//p')
if [ -z "$shlibs" ]; then
	echo "package_linux.sh: dpkg-shlibdeps named no dependencies (see $work/shlibdeps/shlibdeps.log)" >&2
	exit 1
fi
cat > "$debroot/DEBIAN/control" << EOF
Package: chthonia
Version: $ver-$debrel
Section: devel
Priority: optional
Architecture: $deb_arch
Maintainer: $maint
Depends: libwebkitgtk-6.0-4, libgtk-4-1, $shlibs
Homepage: $home
Description: $summary
$(printf '%s\n' "$desc" | sed 's/^/ /')
EOF
if [ "$apparmor" = 1 ]; then
	# The shape of Ubuntu's own profiles for its WebKit programs
	# (epiphany, devhelp): unconfined, with user namespaces. postinst
	# loads it as dh_apparmor's snippet does.
	mkdir -p "$debroot/etc/apparmor.d"
	cat > "$debroot/etc/apparmor.d/chthonia" << 'EOF'
# Chthonia's window is WebKitGTK, whose sandbox (bwrap) needs user
# namespaces. This profile allows everything else, as before; it only
# names the program so AppArmor grants them.

abi <abi/4.0>,
include <tunables/global>

profile chthonia /usr/lib/chthonia/bin/chthonia flags=(unconfined) {
  userns,

  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/chthonia>
}
EOF
	echo /etc/apparmor.d/chthonia > "$debroot/DEBIAN/conffiles"
	cat > "$debroot/DEBIAN/postinst" << 'EOF'
#!/bin/sh
set -e
if [ "$1" = configure ] && aa-enabled --quiet 2>/dev/null; then
	apparmor_parser -r -T -W /etc/apparmor.d/chthonia || true
fi
EOF
	chmod 0755 "$debroot/DEBIAN/postinst"
fi
plain_modes "$debroot"
deb=chthonia_$ver-${debrel}_$deb_arch.deb
dpkg-deb --build --root-owner-group "$debroot" "$dist/$deb" > /dev/null
check "$deb" "$(dpkg-deb -c "$dist/$deb" | awk '$1 !~ /^d/ { print $6 }' | sed -n 's|^\./usr/||p')" "$debroot/usr"
check_modes "$deb" "$(dpkg-deb -c "$dist/$deb")"
etc=$(dpkg-deb -c "$dist/$deb" | awk '$1 !~ /^d/ { print $6 }' | grep -v '^\./usr/' || true)
want=
[ "$apparmor" = 1 ] && want=./etc/apparmor.d/chthonia
if [ "$etc" != "$want" ]; then
	echo "package_linux.sh: $deb installs '$etc' outside /usr, not '$want'" >&2
	exit 1
fi
if [ "$deb_only" = 1 ]; then
	refresh_sums "$dist" "$deb"
	echo "package_linux.sh: $dist/$deb (madc $madc_ver)"
	exit 0
fi

# ---- rpm ----
rpmtop=$work/rpm
mkdir -p "$rpmtop/BUILD" "$rpmtop/RPMS" "$rpmtop/SPECS" "$rpmtop/SOURCES"
buildroot=$rpmtop/BUILDROOT/chthonia-$ver-$rel.$rpm_arch
stage_system "$buildroot/usr"
plain_modes "$buildroot"
cat > "$rpmtop/SPECS/chthonia.spec" << EOF
Name: chthonia
Version: $ver
Release: $rel
Summary: $summary
License: MPL-2.0
URL: $home
AutoReq: yes
AutoProv: no
Requires: webkitgtk6.0
Requires: gtk4
%global __requires_exclude ^lib(madc|madcide|madcgit|madcmark|madcwebview)[-.]
%define debug_package %{nil}
%define __strip /bin/true
%define _build_id_links none

%description
$desc

%files
/usr/bin/chthonia
/usr/lib/chthonia
/usr/share/applications/chthonia.desktop
/usr/share/icons/hicolor/*/apps/chthonia.png
/usr/share/doc/chthonia
EOF
rpmbuild --define "_topdir $rpmtop" --buildroot "$buildroot" -bb "$rpmtop/SPECS/chthonia.spec" > "$work/rpmbuild.log" 2>&1 \
	|| { tail -20 "$work/rpmbuild.log" >&2; exit 1; }
rpm=chthonia-$ver-$rel.$rpm_arch.rpm
cp "$rpmtop/RPMS/$rpm_arch/$rpm" "$dist/"
# rpmbuild removes its build root; the deb's is the same staging.
check "$rpm" "$(rpm -qlvp "$dist/$rpm" | awk '$1 !~ /^d/ { print ($(NF-1) == "->") ? $(NF-2) : $NF }' | sed 's|^/usr/||')" "$debroot/usr"
check_modes "$rpm" "$(rpm -qlvp "$dist/$rpm")"

# ---- tarball: one folder, madc's tarball with Chthonia in it ----
tarstage=$work/tar
folder=chthonia-$ver-linux-$rpm_arch
stage "$tarstage/$folder"
plain_modes "$tarstage"
tgz=$folder.tar.gz
tar -C "$tarstage" --owner=0 --group=0 -czf "$dist/$tgz" "$folder"
check "$tgz" "$(tar -tzf "$dist/$tgz" | grep -v '/$')" "$tarstage"
check_modes "$tgz" "$(tar -tzvf "$dist/$tgz")"

refresh_sums "$dist" "$deb" "$rpm" "$tgz"
echo "package_linux.sh: $dist/{$deb,$rpm,$tgz} (madc $madc_ver)"
