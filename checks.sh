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
  "Update sources.list")
    grep -E '^deb ' /etc/apt/sources.list 2>/dev/null | grep -qE 'main.*contrib.*non-free.*non-free-firmware'
    ;;
  "Update debian.sources")
    grep -rh "^Components:" /etc/apt/sources.list.d/*.sources 2>/dev/null |
    grep -q "main" &&
    grep -rh "^Components:" /etc/apt/sources.list.d/*.sources 2>/dev/null |
    grep -q "contrib" &&
    grep -rh "^Components:" /etc/apt/sources.list.d/*.sources 2>/dev/null |
    grep -q "non-free" &&
    grep -rh "^Components:" /etc/apt/sources.list.d/*.sources 2>/dev/null |
    grep -q "non-free-firmware"
    ;;
  hyprland) exit 0 ;;
  docker) command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 ;;
  "Teste 04") exit 0 ;;
  "Teste 05") [ -f "/opt/teste04/instalado.flag" ] ;;
  *) echo "❌ Recurso desconhecido: '$RESOURCE'" >&2; exit 1 ;;
esac
