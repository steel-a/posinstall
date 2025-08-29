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
  # controle de brilho
  xbacklight \
  libnotify-bin \
  polybar \
  rofi \
  # barra, lançador, notificações
  dunst \        
  # background
  feh \          
  # print screen
  flameshot \    
  lxappearance \
  gtk2-engines-murrine \
  # integração com GTK
  gnome-themes-extra \  
  network-manager-gnome \
  # clipboard no terminal
  xclip \        
  # gerenciador de energia (pode não funcionar 100% no i3)
  xfce4-power-manager \  
  # inclui dmenu, slock
  suckless-tools \       
  xdg-desktop-portal \
  xdg-desktop-portal-gtk

echo "✅ Instalação concluída!"
echo "💡 Dica: configure seu ~/.config/i3/config para integrar esses recursos."
