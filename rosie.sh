#!/bin/bash

# If not already sudoed, sudo
if [ "$EUID" -ne 0 ]; then
    sudo "$0" "$@"
    exit
fi

#!/bin/bash
WDIR=$(pwd)

# Install updates first
 apt-get update
 apt-get upgrade -y


# Install basics
# media things
 apt install imagemagick-6.q16 webp gimp ffmpeg vlc -y
# Serial terminals
 apt install minicom picoterm putty -y
# Filesystem
 apt install 7zip libfuse2 ncdu -y
 apt install caffeine gnome-tweaks neofetch -y
 apt install htop typecatcher -y
 apt install thefuck -y
 apt install sl cowsay -y
 apt install curl -y
 apt install python3-pip pipx -y
 apt install -y libimage-exiftool-perl libposix-strptime-perl libencode-eucjpascii-perl libencode-hanextra-perl libpod2-base-perl

# Pipx autocomplete
if ! grep 'eval "$(register-python-argcomplete pipx)"' /home/$SUDO_USER/.bashrc >&2; then
  echo 'eval "$(register-python-argcomplete pipx)"' >> /home/$SUDO_USER/.bashrc
fi

# CAD Tools
if ! command -v kicad >&2; then
   add-apt-repository --yes ppa:kicad/kicad-8.0-releases
   apt update
   apt install --install-recommends kicad -y
else
  echo "KiCAD already installed"
fi

 snap install tio --classic
 snap install code --classic
 snap install nmap
 snap connect nmap:network-control

 snap install discord
 snap install telegram-desktop

# Tools for fetching and building things from source
 apt install build-essential cmake git pkg-config -y
 apt install libusb-dev libusb-1.0-0-dev -y

cd $WDIR
if ! [ -d /home/$SUDO_USER/repos ]; then
  mkdir /home/$SUDO_USER/repos;
fi

# Micromamba
if [ -f /home/$SUDO_USER/.local/bin/micromamba ]; then
  echo "micromamba already installed"
else
  su $SUDO_USER -c '"${SHELL}" <(curl -L micro.mamba.pm/install.sh)'
fi

# Rust
if [ -d /home/$SUDO_USER/.cargo ]; then
  echo "rust already installed"
else
  su $SUDO_USER -c "curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y"
fi

# Do git things
cd /home/$SUDO_USER/repos

# Install RTL-SDR library
cd /home/$SUDO_USER/repos
if ! command -v rtl_sdr >&2; then
  if ! [ -d librtlsdr ]; then
    git clone https://github.com/librtlsdr/librtlsdr.git
    cd librtlsdr
    git status
    git checkout master
    mkdir build && cd build
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
    make
    make install
    ldconfig
  fi
else
  echo "rtl_sdr already installed"
fi
# Install Kismet sniffing tools
if ! command -v kismet >&2; then
  wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key --quiet | gpg --dearmor |  tee /usr/share/keyrings/kismet-archive-keyring.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/kismet-archive-keyring.gpg] https://www.kismetwireless.net/repos/apt/git/noble noble main' |  tee /etc/apt/sources.list.d/kismet.list >/dev/null
   apt update
   DEBIAN_FRONTEND=noninterative apt install kismet -y > /dev/null
   usermod -aG kismet $SUDO_USER
else
  echo "kismet already installed"
fi

# Wireshark
if ! command -v wireshark >&2; then
   add-apt-repository ppa:wireshark-dev/stable
   apt update
   DEBIAN_FRONTEND=noninterative apt install wireshark -y > /dev/null
   apt install -y tshark
   usermod -a -G wireshark "$SUDO_USER"
fi

# Universal Radio Hacker
su $SUDO_USER -c '
if ! command -v urh >&2; then
pipx install urh
pipx ensurepath
else
echo "urh already installed"
fi
'
if ! [ -f /etc/udev/rules.d/10-rtl-sdr.rules ]; then
  cp $WDIR/10-rtl-sdr.rules /etc/udev/rules.d
fi

# Signal
if ! command -v signal-desktop >&2; then
  wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
  cat signal-desktop-keyring.gpg |  tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
     tee /etc/apt/sources.list.d/signal-xenial.list
   apt update &&  apt install -y signal-desktop
  rm signal-desktop-keyring.gpg
else
  echo "signal already installed"
fi

mkdir /home/$SUDO_USER/.local/share/icons

if ! [ -f /home/$SUDO_USER/.local/share/applications/obsidian.desktop ]; then
  cd /home/$SUDO_USER/.local/bin
  wget -nc -P /home/$SUDO_USER/.local/bin https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage
  chmod u+x /home/$SUDO_USER/.local/bin/Obsidian-1.6.7.AppImage
  /home/$SUDO_USER/.local/bin/Obsidian-1.6.7.AppImage --appimage-extract
  mv squashfs-root/usr/share/icons/hicolor/512x512/apps/obsidian.png /home/$SUDO_USER/.local/share/icons
  rm -rf squashfs-root
  echo "
[Desktop Entry]
Name=Obsidian
Exec=/home/$SUDO_USER/.local/bin/Obsidian-1.6.7.AppImage --no-sandbox %U
Terminal=false
Type=Application
Icon=/home/$SUDO_USER/.local/share/icons/obsidian.png
StartupWMClass=obsidian
X-AppImage-Version=1.6.7
Comment=Obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
" > /home/$SUDO_USER/.local/share/applications/obsidian.desktop
chmod 555 /home/$SUDO_USER/.local/share/applications/obsidian.desktop
fi

if ! [ -f /home/$SUDO_USER/.local/share/applications/arduino.desktop ]; then
  cd /home/$SUDO_USER/.local/bin
  wget -nc -P /home/$SUDO_USER/.local/bin https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.2_Linux_64bit.AppImage
  chmod u+x /home/$SUDO_USER/.local/bin/arduino-ide_2.3.2_Linux_64bit.AppImage
  /home/$SUDO_USER/.local/bin/arduino-ide_2.3.2_Linux_64bit.AppImage --appimage-extract
  mv squashfs-root/usr/share/icons/hicolor/512x512/apps/arduino-ide.png /home/$SUDO_USER/.local/share/icons
  rm -rf squashfs-root
  echo "
[Desktop Entry]
Name=Arduino IDE
Exec=/home/$SUDO_USER/.local/bin/arduino-ide_2.3.2_Linux_64bit.AppImage --no-sandbox %U
Terminal=false
Type=Application
Icon=/home/$SUDO_USER/.local/share/icons/arduino-ide.png
StartupWMClass=Arduino IDE
X-AppImage-Version=2.3.2
Comment=Arduino IDE
Categories=Development;
" > /home/$SUDO_USER/.local/share/applications/arduino.desktop
chmod 555 /home/$SUDO_USER/.local/share/applications/arduino.desktop
fi

if ! [ -f /home/$SUDO_USER/.local/share/applications/qflipper.desktop ]; then
  cd /home/$SUDO_USER/.local/bin
  wget -nc -P /home/$SUDO_USER/.local/bin https://update.flipperzero.one/builds/qFlipper/1.3.3/qFlipper-x86_64-1.3.3.AppImage
  chmod u+x /home/$SUDO_USER/.local/bin/qFlipper-x86_64-1.3.3.AppImage
  /home/$SUDO_USER/.local/bin/qFlipper-x86_64-1.3.3.AppImage --appimage-extract
  mv squashfs-root/usr/share/icons/hicolor/512x512/apps/qFlipper.png /home/$SUDO_USER/.local/share/icons
  rm -rf squashfs-root
  echo "
[Desktop Entry]
Type=Application
StartupWMClass=qFlipper
Categories=Utility;Education
Comment=Update your Flipper easily
Icon=/home/$SUDO_USER/.local/share/icons/qFlipper.png
Name=qFlipper
Exec=/home/$SUDO_USER/.local/bin/qFlipper-x86_64-1.3.3.AppImage
Terminal=false
X-AppImage-Version=bfce851
" > /home/$SUDO_USER/.local/share/applications/qflipper.desktop
chmod 555 /home/$SUDO_USER/.local/share/applications/qflipper.desktop
fi


 systemctl daemon-reload


# VSCode Extensions
su $SUDO_USER -c "
code --install-extension ms-python.python --install-extension ms-vscode.cpptools
"


# Update user permissions
usermod -a -G dialout $SUDO_USER
usermod -a -G tty $SUDO_USER
