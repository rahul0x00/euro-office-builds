#!/bin/bash
set -e
# Install prerequisites
pacman -Syu --noconfirm git sudo docker jq wget fuse2 desktop-file-utils grep awk cpio
useradd -m builder
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Fix docker permissions
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
groupadd -g "$DOCKER_GID" docker 2>/dev/null || groupmod -g "$DOCKER_GID" docker 2>/dev/null || true
usermod -aG docker builder
chmod 666 /var/run/docker.sock

# Verify docker works for builder
sudo -u builder docker ps

# Install yay
sudo -u builder bash -c "cd /home/builder && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm"

# Clone and patch package
sudo -u builder git clone https://aur.archlinux.org/euro-office-desktopeditors-git.git /home/builder/pkg
cd /home/builder/pkg
TAG="v9.4.0"
PKGVER="9.4.0"
sed -i '/pkgver() {/,/}/d' PKGBUILD
sed -i "s/pkgver=.*/pkgver=$PKGVER/g" PKGBUILD
sed -i "s/pkgname=euro-office-desktopeditors-git/pkgname=euro-office-desktopeditors/g" PKGBUILD
sed -i "s/conflicts=.*/conflicts=('euro-office-desktopeditors-git')/g" PKGBUILD
sed -i "s|source=(\"git+https://github.com/Euro-Office/DesktopEditors.git\")|source=(\"git+https://github.com/Euro-Office/DesktopEditors.git#tag=$TAG\")|g" PKGBUILD
sed -i '/cd "$srcdir\/DesktopEditors"/a \ \ git fetch origin main \&\& git checkout FETCH_HEAD -- build' PKGBUILD
chown -R builder:builder /home/builder/pkg

# Install libtiff5 dependency using yay
sudo -u builder yay -S --noconfirm libtiff5

# Now finally build!
sudo -u builder makepkg -s --noconfirm
