#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BASE="distros/$DISTRO"

# 📦 Verifica se o 'dialog' está instalado
if ! command -v dialog >/dev/null 2>&1; then
  echo "❌ O utilitário 'dialog' não está instalado."
  echo "ℹ️ Instale com: sudo apt install dialog  # ou sudo dnf install dialog"
  exit 1
fi

# 🔍 Função para listar arquivos e pastas de um caminho no GitHub
list_github_items() {
  local path="$1"
  local api_url="https://api.github.com/repos/$(echo "$REPO_BASE" | cut -d'/' -f4,5)/contents/$path?ref=$(echo "$REPO_BASE" | cut -d'/' -f6)"
  curl -fsSL "$api_url"
}

# 📋 Função para montar menu interativo com dialog
show_menu() {
  local path="$1"
  local json=$(list_github_items "$path")
  local options=()
  local found_items=false

  while IFS= read -r line; do
    name=$(echo "$line" | grep '"name":' | cut -d '"' -f4)
    type=$(echo "$line" | grep '"type":' | cut -d '"' -f4)

    [[ -z "$name" || -z "$type" ]] && continue

    if [[ "$type" == "dir" ]]; then
      options+=("$name/" "📁 Pasta")
      found_items=true
    elif [[ "$type" == "file" && "$name" == *.sh && "$name" != *-check.sh ]]; then
      options+=("${name%.sh}" "📦 Script")
      found_items=true
    fi
  done <<< "$(echo "$json" | tr -d '\r')"

  options+=("sair" "🚪 Sair")

  if [[ "$found_items" == false ]]; then
    dialog --msgbox "Nenhum script ou pasta encontrado em '$path'." 8 50
    clear
    exit 1
  fi

  CHOICE=$(dialog --clear --title "Menu: $path" \
    --menu "Selecione uma opção:" 20 60 15 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)

  clear

  if [[ "$CHOICE" == "sair" ]]; then
    echo "🚪 Saindo..."
    exit 0
  elif [[ "$CHOICE" == */ ]]; then
    show_menu "$path/${CHOICE%/}"
  else
    local script_url="$REPO_BASE/$path/$CHOICE.sh"
    if curl --head --silent --fail "$script_url" > /dev/null; then
      bash <(curl -sSL "$script_url")
    else
      echo "❌ Script não encontrado: $CHOICE"
    fi
  fi
}

# 🚀 Inicia menu na pasta da distribuição
show_menu "$BASE"
