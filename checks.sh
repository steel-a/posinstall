#!/bin/bash

RESOURCE="$1"

case "$RESOURCE" in
  i3)
    command -v i3 >/dev/null 2>&1 &&
    command -v picom >/dev/null 2>&1 &&
    command -v polybar >/dev/null 2>&1 &&
    command -v rofi >/dev/null 2>&1 &&
    command -v dunst >/dev/null 2>&1 &&
    command -v feh >/dev/null 2>&1 &&
    command -v flameshot >/dev/null 2>&1 &&
    command -v lxappearance >/dev/null 2>&1 &&
    command -v nm-connection-editor >/dev/null 2>&1 &&
    command -v xclip >/dev/null 2>&1 &&
    command -v xfce4-power-manager >/dev/null 2>&1 &&
    command -v dmenu >/dev/null 2>&1 &&
    command -v slock >/dev/null 2>&1
    ;;
"Update debian.sources")
  REQUIRED=("main" "contrib" "non-free" "non-free-firmware")
  grep "^Components:" /etc/apt/sources.list.d/debian.sources | while read -r line; do
    for comp in "${REQUIRED[@]}"; do
      echo "$line" | grep -q "$comp" || exit 1
    done
  done
  ;;
  
Hyprland)
  command -v hyprland >/dev/null 2>&1 &&
  command -v brightnessctl >/dev/null 2>&1 &&
  command -v notify-send >/dev/null 2>&1 &&
  command -v waybar >/dev/null 2>&1 &&
  command -v wofi >/dev/null 2>&1 &&
  command -v mako >/dev/null 2>&1 &&
  command -v swaybg >/dev/null 2>&1 &&
  command -v grim >/dev/null 2>&1 &&
  command -v slurp >/dev/null 2>&1 &&
  command -v lxappearance >/dev/null 2>&1 &&
  command -v nm-connection-editor >/dev/null 2>&1 &&
  command -v wl-copy >/dev/null 2>&1 &&
  command -v swayidle >/dev/null 2>&1 &&
  command -v swaylock >/dev/null 2>&1 &&
  dpkg -s power-profiles-daemon >/dev/null 2>&1 &&
  dpkg -s xdg-desktop-portal >/dev/null 2>&1 &&
  dpkg -s xdg-desktop-portal-hyprland >/dev/null 2>&1 &&
  dpkg -s xdg-desktop-portal-wlr >/dev/null 2>&1
  ;;
Audio-Desktop)
  command -v pavucontrol >/dev/null 2>&1 &&
  command -v pulsemixer >/dev/null 2>&1 &&
  command -v pamixer >/dev/null 2>&1 &&
  dpkg -s pipewire-audio >/dev/null 2>&1
  ;;
  docker) command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 ;;
  "Teste 04") exit 0 ;;
  "Teste 05") [ -f "/opt/teste04/instalado.flag" ] ;;
  *) echo "❌ Recurso desconhecido: '$RESOURCE'" >&2; exit 1 ;;
esac
