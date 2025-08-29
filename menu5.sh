#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
CURRENT_PATH=""
BASE="$REPO_BASE/distros/$DISTRO"

script_exists() {
  curl --head --silent --fail "$1" > /dev/null
}

discover_resources() {
  resources=()
  folders=()
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  local index_url="https://api.github.com/repos/$user/$repo/contents/distros/$DISTRO/$CURRENT_PATH?ref=$branch"
  local response=$(curl -s "$index_url")

  # Listar arquivos .sh
  echo "$response" | grep '"name":' | cut -d '"' -f4 | while read -r file; do
    if [[ "$file" == *.sh && "$file" != *-check.sh ]]; then
      local name="${file%.sh}"
      [[ -n "$name" ]] && resources+=("$name")
    fi
  done

  # Listar subpastas
  echo "$response" | grep '"type": "dir"' -B1 | grep '"name":' | cut -d '"' -f4 | while read -r folder; do
    folders+=("$folder")
  done
}

show_resource_status() {
  local name="$1"
  local install_script="$BASE/$CURRENT_PATH/${name}.sh"
  local check_script="$BASE/$CURRENT_PATH/${name}-check.sh"

  local has_install=false
  local has_check=false

  script_exists "$install_script" && has_install=true
  script_exists "$check_script" && has_check=true

  if [ "$has_install" = false ]; then
    echo "❌ $name (instalação não disponível)"
    return
  fi

  if [ "$has_check" = false ]; then
    echo "⚠️ $name (checagem ausente)"
    return
  fi

  local status=$(bash <(curl -sSL "$check_script"))
  if [[ "$status" == "🟢" ]]; then
    echo "🟢 $name [checado instalado]"
  else
    echo "🟡 $name [checado não instalado]"
  fi
}

# Verifica se o terminal é interativo
if [[ ! -t 1 ]]; then
  echo "❌ Terminal não interativo. Execute o script em um terminal real."
  exit 1
fi

while true; do
  discover_resources

  menu_list=()

  # Adiciona pastas ao menu
  for folder in "${folders[@]}"; do
    menu_list+=("📁 $folder")
  done

  # Adiciona scripts ao menu
  for name in "${resources[@]}"; do
    if [[ -n "$name" ]]; then
      status=$(show_resource_status "$name" | tail -n1)
      menu_list+=("$name - $status")
    fi
  done

  # Adiciona opções de navegação
  [[ -n "$CURRENT_PATH" ]] && menu_list+=("🔙 Voltar")
  menu_list+=("❌ Sair")

  selected=$(
    printf "%s\n" "${menu_list[@]}" | fzf \
      --prompt="📂 Navegando em: ${DISTRO}/${CURRENT_PATH:-raiz} ➜ " \
      --height=100% \
      --border \
      --layout=reverse
  )

  opcao=$(echo "$selected" | cut -d' ' -f2)

  if [[ "$selected" == "❌ Sair" ]]; then
    echo "👋 Saindo..."
    break
  elif [[ "$selected" == "🔙 Voltar" ]]; then
    CURRENT_PATH=$(dirname "$CURRENT_PATH")
    [[ "$CURRENT_PATH" == "." ]] && CURRENT_PATH=""
  elif [[ "$selected" == 📁* ]]; then
    CURRENT_PATH="${CURRENT_PATH}/${opcao}"
    CURRENT_PATH="${CURRENT_PATH#/}"  # remove barra inicial
  else
    install_script="$BASE/$CURRENT_PATH/${opcao}.sh"
    if script_exists "$install_script"; then
      echo ""
      echo "🔧 Instalando $opcao..."
      bash <(curl -sSL "$install_script")
    else
      echo "❌ Opção inválida ou script não disponível."
    fi
    echo ""
    read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
    clear
  fi
done
