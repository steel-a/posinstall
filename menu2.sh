#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"

# Verifica dependência do jq
if ! command -v jq &> /dev/null; then
  echo "❌ 'jq' não está instalado. Instale com: sudo apt install jq"
  exit 1
fi

script_exists() {
  curl --head --silent --fail "$1" > /dev/null
}

discover_resources() {
  resources=()
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  fetch_files_recursively() {
    local path="$1"
    local api_url="https://api.github.com/repos/$user/$repo/contents/$path?ref=$branch"
    local response=$(curl -s "$api_url")

    echo "$response" | jq -r '.[] | @base64' | while read -r item; do
      _jq() {
        echo "$item" | base64 --decode | jq -r "$1"
      }

      local type=$(_jq '.type')
      local name=$(_jq '.name')
      local full_path=$(_jq '.path')

      if [[ "$type" == "dir" ]]; then
        fetch_files_recursively "$full_path"
      elif [[ "$type" == "file" && "$name" == *.sh && "$name" != *-check.sh ]]; then
        local resource_name="${full_path#distros/$DISTRO/}"
        resource_name="${resource_name%.sh}"
        [[ -n "$resource_name" ]] && resources+=("$resource_name")
      fi
    done
  }

  fetch_files_recursively "distros/$DISTRO"
}

show_resource_status() {
  local name="$1"
  local install_script="$REPO_BASE/distros/$DISTRO/${name}.sh"
  local check_script="$REPO_BASE/distros/$DISTRO/${name}-check.sh"

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
  for name in "${resources[@]}"; do
    if [[ -n "$name" ]]; then
      status=$(show_resource_status "$name" | tail -n1)
      menu_list+=("$name - $status")
    fi
  done

  menu_list+=("Sair - ❌ Encerrar o script")

  selected=$(
    printf "%s\n" "${menu_list[@]}" | fzf \
      --prompt="🔧 Pós-Instalação para $DISTRO. Use as setas para navegar e Enter para selecionar:" \
      --height=100% \
      --border \
      --layout=reverse
  )

  opcao=$(echo "$selected" | cut -d' ' -f1)

  if [[ "$opcao" == "Sair" ]]; then
    echo "👋 Saindo..."
    break
  fi

  install_script="$REPO_BASE/distros/$DISTRO/${opcao}.sh"
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
done
