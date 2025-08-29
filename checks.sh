#!/bin/bash

RESOURCE="$1"

case "$RESOURCE" in
  hyprland) exit 0 ;;
  docker) command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 ;;
  "Teste 04") [ -f "/opt/teste04/instalado.flag" ] ;;
  *) echo "❌ Recurso desconhecido: '$RESOURCE'" >&2; exit 1 ;;
esac
