#!/bin/bash

# From https://github.com/ptitSeb/box64/blob/main/docs/X64WINE.md#examples
branch="devel" # example: devel, staging, or stable (wine-staging 4.5+ requires libfaudio0:i386)
version="7.1" # example: "7.1"
id="debian" # example: debian, ubuntu
dist="bookworm" # example (for debian): bullseye, buster, jessie, wheezy, ${VERSION_CODENAME}, etc 
tag="-1" # example: -1 (some wine .deb files have -1 tag on the end and some don't)

USER=user

new_user() {
  useradd -m -s /bin/bash $USER
}

add_src() {
  echo "Adding box86 and box64 deb sources"
  sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/' /etc/apt/sources.list
  sed -i 's/security.debian.org/mirrors.ustc.edu.cn/' /etc/apt/sources.list
  apt update
  apt install -y gpg
  curl -L https://ryanfortner.github.io/box64-debs/box64.list -o /etc/apt/sources.list.d/box64.list
  curl -L https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
  curl -L https://ryanfortner.github.io/box86-debs/box86.list -o /etc/apt/sources.list.d/box86.list
  curl -L https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
}

install_box86() {
  echo "Installing box86 and box64"
  dpkg --add-architecture armhf
  apt update
  apt install -y box64-android libc6:armhf box86-android:armhf
  apt install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
    libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libldap-common:armhf libopenal1:armhf libpcap0.8:armhf \
    libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
    libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libncurses5:armhf libcap2-bin:armhf libcups2:armhf \
    libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
    libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc1:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
    libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
    libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
  apt install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
    libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libldap-common:arm64 libopenal1:arm64 libpcap0.8:arm64 \
    libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
    ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
    libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
    libgssapi-krb5-2:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
    libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
    libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
}

install_wine() {
  # Wine download links from WineHQ: https://dl.winehq.org/wine-builds/
  MIRROR=mirrors.tuna.tsinghua.edu.cn
  LNKA="https://${MIRROR}/wine-builds/${id}/dists/${dist}/main/binary-amd64/" # amd64-wine links
  DEB_A1="wine-${branch}-amd64_${version}~${dist}${tag}_amd64.deb" # wine64 main bin
  DEB_A2="wine-${branch}_${version}~${dist}${tag}_amd64.deb" # wine64 support files (required for wine64 / can work alongside wine_i386 main bin)
  LNKB="https://${MIRROR}/wine-builds/${id}/dists/${dist}/main/binary-i386/" # i386-wine links
  DEB_B1="wine-${branch}-i386_${version}~${dist}${tag}_i386.deb" # wine_i386 main bin
  #DEB_B2="wine-${branch}_${version}~${dist}${tag}_i386.deb" # wine_i386 support files (required for wine_i386 if no wine64 / CONFLICTS WITH wine64 support files)

  # Install amd64-wine (64-bit) alongside i386-wine (32-bit)
  echo "Downloading and extracting wine"
  curl -O ${LNKA}${DEB_A1}
  dpkg-deb -x ${DEB_A1} wine-installer &
  curl -O ${LNKA}${DEB_A2}
  dpkg-deb -x ${DEB_A2} wine-installer &
  curl -O ${LNKB}${DEB_B1}
  dpkg-deb -x ${DEB_B1} wine-installer
  echo "Installing wine"
  [ ! -d "/opt" ] && mkdir /opt
  mv wine-installer/opt/wine* /opt/wine
  rm -rf wine-installer *.deb
}

generate_shortcut() {
  echo "Generating shortcut scripts"
  cat > /opt/box86wine << EOF
case "\$1" in
  32|32gl4|64|64gl4)
    export DISPLAY=:0
    export PULSE_SERVER=tcp:127.0.0.1:4713
    export BOX86_PATH=/opt/wine/bin
    export GALLIUM_DRIVER=virpipe
    ;;
  *)
    echo "Usage: \$0 [32|32gl4|64|64gl4] [EXE]"
    exit
    ;;
esac
if [ "\$1" = "32gl4" ] || [ "\$1" = "64gl4" ]; then
  export MESA_GL_VERSION_OVERRIDE=4.0
fi
if [ "\$1" = "32" ] || [ "\$1" = "32gl4" ]; then
  shift
  box86 wine "\$@"
else
  shift
  box64 wine64 "\$@"
fi
EOF
  chmod 755 /opt/box86wine
}

new_user
add_src
install_box86
install_wine
generate_shortcut
cat << EOF
--- box86 box64 wine setup complete! ---
Shortcut scripts at /opt/box86wine
EOF