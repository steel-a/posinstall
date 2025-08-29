#!/bin/bash

set -e

echo "🔧 Atualizando lista de pacotes..."
sudo apt update

echo "📦 Instalando pacotes essenciais para o i3..."
sudo apt install -y \
  xorg \
  xbindkeys \
  xvkbd \
  xinput \
  i3 \
  sxhkd \
  xdotool \
  picom \
  xbacklight \  # controle de brilho
  libnotify-bin \
  polybar \
  rofi \
  dunst \        # barra, lançador, notificações
  feh \          # background
  flameshot \    # print screen
  lxappearance \
  gtk2-engines-murrine \
  gnome-themes-extra \  # integração com GTK
  network-manager-gnome \
  xclip \        # clipboard no terminal
  xfce4-power-manager \  # gerenciador de energia (pode não funcionar 100% no i3)
  suckless-tools \       # inclui dmenu, slock
  xdg-desktop-portal \
  xdg-desktop-portal-gtk

echo "✅ Instalação concluída!"
echo "💡 Dica: configure seu ~/.config/i3/config para integrar esses recursos."
