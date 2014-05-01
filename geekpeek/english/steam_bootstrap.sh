#!/bin/bash
#
#Steam installer for Debian wheezy (32- and 64-bit)
#
# Place into empty directory and run.
#
 
download() {
	local url="$1"
	local filename="$(basename "$url")"
	 
	if [ ! -f "$filename" ]; then
		wget -c "$url" -O "$filename.part"
		mv "$filename.part" "$filename"
	fi
}
 
package() {
	local url="$1"
	local target="$2"
	 
download "$url"
 
mkdir -p "$target"
ar p "$(basename "$url")" data.tar.gz | tar xz -C "$target"
}
 
set -e
 
package http://media.steampowered.com/client/installer/steam.deb "${PWD}/tree"
 
STEAMPACKAGE="steam"
STEAMCONFIG="${HOME}/.steam"
STEAMDATALINK="${STEAMCONFIG}/${STEAMCONFIG}"
STEAMBOOTSTRAP="steam.sh"
LAUNCHSTEAMDIR="$(readlink -eq "${STEAMDATALINK}" || echo)"
LAUNCHSTEAMPLATFORM="ubuntu12_32"
LAUNCHSTEAMBOOTSTRAPFILE="${PWD}/tree/usr/lib/steam/bootstraplinux_${LAUNCHSTEAMPLATFORM}.tar.xz"
STEAM_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
CLASSICSTEAMDIR="$HOME/Steam"
DEFAULTSTEAMDIR="$STEAM_DATA_HOME/Steam"
 
STEAMDIR="${DEFAULTSTEAMDIR}"
 
if [ ! -d "$STEAMCONFIG" ]; then
	mkdir "$STEAMCONFIG"
fi
 
echo "Setting up Steam content in $STEAMDIR"
 
mkdir -p "${STEAMDIR}"
tar xJf "${LAUNCHSTEAMBOOTSTRAPFILE}" -C "${STEAMDIR}"
 
cat > "${STEAMDIR}/steam_on_debian.sh" <<EOF
#!/bin/sh
STEAMDIR="\$(readlink -f "\$(dirname "\$0")")"
if [ -z "\${LD_LIBRARY_PATH}" ]; then
	LD_LIBRARY_PATH="\${STEAMDIR}/compat_libraries/lib/i386-linux-gnu"
else
	LD_LIBRARY_PATH="\${STEAMDIR}/compat_libraries/lib/i386-linux-gnu:\${LD_LIBRARY_PATH}"
fi
 
export LD_LIBRARY_PATH
 
exec "\${STEAMDIR}/steam.sh" "\$@"
EOF
 
chmod +x "${STEAMDIR}/steam_on_debian.sh"
 
echo "Installing Ubuntu packages"
 
mkdir -p "${STEAMDIR}/compat_libraries"
package http://security.ubuntu.com/ubuntu/pool/main/e/eglibc/libc6_2.15-0ubuntu10.2_i386.deb "${STEAMDIR}/compat_libraries"
 
echo "Installing desktop files"
mkdir -p "${STEAM_DATA_HOME}/applications"
sed "s!/usr/bin/steam!${STEAMDIR}/steam_on_debian.sh!" tree/usr/share/applications/steam.desktop > "${STEAM_DATA_HOME}/applications/steam.desktop"
cp -R tree/usr/share/icons "${STEAM_DATA_HOME}"
 
echo "Adding Steam to PATH"
MAGIC_LINE="[[ -f \"${STEAMDIR}/setup_debian_environment.sh\" ]] && source \"${STEAMDIR}/setup_debian_environment.sh\""
 
cat > "${STEAMDIR}/setup_debian_environment.sh" <<EOF
if ! which steam > /dev/null 2>&1; then
	PATH="${STEAMDIR}/debian_bin:${PATH}"
	export PATH
fi
EOF
 
mkdir -p "${STEAMDIR}/debian_bin"
 
cat > "${STEAMDIR}/debian_bin/steam" <<EOF
#!/bin/sh
exec "${STEAMDIR}/steam_on_debian.sh" "$@"
EOF
 
chmod +x "${STEAMDIR}/debian_bin/steam"
 
if ! grep -qxF "${MAGIC_LINE}" "${HOME}/.bashrc"; then
	echo "$MAGIC_LINE" >> "${HOME}/.bashrc"
	 
	echo
	echo "Steam was added to your profile. Please relogin or source ~/.bashrc."
	echo
fi
 
echo "To uninstall:"
echo "rm -rf ${STEAM_DIR}"
echo "rm -f everything steamish from ${STEAM_DATA_HOME}/applications"
echo "remove ${MAGIC_LINE} from ${HOME}/.bashrc"
