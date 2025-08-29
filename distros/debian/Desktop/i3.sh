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
  xclip           # considerar instalar se quiser manipular clipboard no terminal considerar também o `parcellite` ou `clipit` para um clipboard mais avançado
  xfce4-power-manager # power manager - talvez não funcione no I3
  suckless-tools  # dmenu, slock tela de lock
  xdg-desktop-portal # para integrações dos flatpaks
  xdg-desktop-portal-gtk # para integrações dos flatpaks
)

sudo apt install -y "${packages[@]}"


echo "✅ Instalação concluída!"
echo "💡 Dica: configure seu ~/.config/i3/config para integrar esses recursos."
