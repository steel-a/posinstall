#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BRANCH=$(echo "$REPO_BASE" | cut -d'/' -f6)
USER=$(echo "$REPO_BASE" | cut -d'/' -f4)
REPO=$(echo "$REPO_BASE" | cut -d'/' -f5)

# Função para listar conteúdo de uma pasta no GitHub
list_github_folder() {
  local path="$1"
  curl -s "https://api.github.com/repos/$USER/$REPO/contents/$path?ref=$BRANCH"
}

# Função para montar menu interativo com dialog
show_menu() {
  local path="$1"
  local entries=$(list_github_folder "$path")

  local options=()
  while IFS= read -r line; do
    name=$(echo "$line" | jq -r '.name')
    type=$(echo "$line" | jq -r '.type')

    # Ignora arquivos ocultos ou inválidos
    [[ "$name" == "null" || -z "$name" ]] && continue

    if [[ "$type" == "dir" ]]; then
      options+=("$name/" "📁 Pasta")
    elif [[ "$name" == *.sh && "$name" != *-check.sh ]]; then
      options+=("${name%.sh}" "📦 Script")
    fi
  done <<< "$(echo "$entries" | jq -c '.[]')"

  options+=("sair" "🚪 Sair")

  # Mostra menu com dialog
  CHOICE=$(dialog --clear --title "Menu: $path" \
    --menu "Selecione uma opção:" 20 60 15 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)

  clear

  # Processa escolha
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

# Inicia menu na pasta da distribuição
show_menu "distros/$DISTRO"
