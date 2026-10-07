#!/bin/bash
# check_apparmor.sh — the installed Chthonia's window under AppArmor's
# user-namespace restriction (Ubuntu 24.04 and later, by default).
#
#   scripts/check_apparmor.sh [SECONDS]
#
# After madc's and Chthonia's .debs are installed, as a user with sudo and a
# display (xvfb-run where there is none): the profile the .deb installs is
# loaded, the window runs SECONDS (default 15) under it, and, the control,
# the same window ends by itself with the profile unloaded — WebKit's
# sandbox (bwrap) denied its user namespaces.
set -u
secs=${1:-15}
prof=/etc/apparmor.d/chthonia
fail() { echo "check_apparmor: FAIL — $*" >&2; exit 1; }

[ -f "$prof" ] || fail "no $prof (the .deb installs it on Ubuntu 24.04 and later)"
[ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null)" = 1 ] \
	|| fail "the user-namespace restriction is off; this checks the window with it on"
sudo grep -q '^chthonia ' /sys/kernel/security/apparmor/profiles \
	|| fail "the chthonia profile is not loaded (the .deb's postinst loads it)"
echo "check_apparmor: ok — the package's profile is loaded"

src=$(mktemp -d)/hello.c
printf 'int main() { return 0; }\n' > "$src"

# window — the installed chthonia on hello.c, ended after SECONDS: its exit
# status (124 = it was still running).
window() {
	timeout "$secs" chthonia "$src" > /dev/null 2>&1
}

window
rc=$?
[ $rc -eq 124 ] || fail "under the profile the window ended by itself (exit status $rc)"
echo "check_apparmor: ok — under the profile the window ran ${secs}s"

sudo apparmor_parser -R "$prof" || fail "could not unload $prof"
window
rc=$?
sudo apparmor_parser -r -T -W "$prof" || fail "could not load $prof again"
[ $rc -ne 124 ] || fail "control: without the profile the window ran too, so this check cannot see the restriction"
echo "check_apparmor: ok — control: without the profile the window ended (exit status $rc)"
echo "check_apparmor: PASS"
