# This script is used to setup x86(x86_64) Windows exe runtime environment.
# Termux(arm Linux) -> PRoot(arm Linux) -> box86/box64(i386/amd64 Linux) -> wine(i386/amd64 Windows)
# Video: termux-x11, need Termux:X11 app: https://github.com/termux/termux-x11
# Audio: pulseaudio, no app required
# Hardware acceleration: virglrenderer, some exe need this to run

LINUX_DISTRO=debian
USER=user

bootstrap_env() {
  apt update

  # x11-repo for termux-x11-nightly, virglrenderer-android
  apt install -y x11-repo proot-distro pulseaudio
  [ $? != 0 ] && exit $?
  apt install -y termux-x11-nightly virglrenderer-android
  [ $? != 0 ] && exit $?
  proot-distro install $LINUX_DISTRO
}

create_start_scripts() {
  if [ ! -e "install-box86-wine.sh" ]; then
    echo "ERROR: You also need install-box86-wine.sh"
  fi
  cp install-box86-wine.sh $PREFIX/var/lib/proot-distro/installed-rootfs/$LINUX_DISTRO/root
  chmod 775 $PREFIX/var/lib/proot-distro/installed-rootfs/$LINUX_DISTRO/root/install-box86-wine.sh
  cat > startx11d << EOF
# This script is used to start video, audio and hardware acceleration daemon for proot
termux-x11 :0 & virgl_test_server_android &
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
EOF
  
  echo '# This script is used to start PRoot Linux' > startproot
  echo "proot-distro login $LINUX_DISTRO --shared-tmp --user $USER" >> startproot

  chmod 755 startx11d startproot
}

bootstrap_env
create_start_scripts
proot-distro login $LINUX_DISTRO -- bash /root/install-box86-wine.sh
