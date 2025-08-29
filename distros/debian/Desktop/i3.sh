#!/bin/bash

set -e

echo "🔧 Atualizando lista de pacotes..."
sudo apt update

echo "📦 Instalando pacotes essenciais para o i3..."
packages=(
  xorg
  xbindkeys
  xvkbd
  xinput
  i3
  sxhkd
  xdotool
  picom
  xbacklight      # controle de brilho
  libnotify-bin
  polybar
  rofi
  dunst           # barra, lançador, notificações
  feh             # background
  flameshot       # print screen
  lxappearance
  gtk2-engines-murrine
  gnome-themes-extra
  network-manager-gnome
  xclip           # clipboard
  xfce4-power-manager
  suckless-tools
  xdg-desktop-portal
  xdg-desktop-portal-gtk
)

sudo apt install -y "${packages[@]}"


echo "✅ Instalação concluída!"
echo "💡 Dica: configure seu ~/.config/i3/config para integrar esses recursos."
