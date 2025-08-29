#!/bin/bash

set -e

echo "🔧 Atualizando lista de pacotes..."
sudo apt update

echo "📦 Instalando pacotes essenciais para o hyprland..."
packages=(
  hyprland
  brightnessctl # backlight
  libnotify-bin
  waybar wofi mako # barra, lançador, notificações
  swaybg # (ou swww) background
  grim slurp # print screen
  lxappearance # para melhor integração com GTK considerar `gtk2-engines-murrine` e `gnome-themes-extra`
  network-manager-gnome
  wl-clipboard # considerar instalar se quiser manipular clipboard no terminal
  power-profiles-daemon # (ou gnome-power-manager) power manager
  swayidle swaylock # lockscreen
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-wlr # para integrações dos flatpaks Considerar xdg-desktop-portal-gtk também, pois alguns apps GTK ainda dependem dele para diálogos de arquivos.
)

sudo apt install -y "${packages[@]}"


echo "✅ Instalação concluída!"
