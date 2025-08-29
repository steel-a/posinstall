#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BASE="$REPO_BASE/distros/$DISTRO"

# Codifica strings para uso seguro em URLs
urlencode() {
  local string="$1"
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<${#string} ; pos++ )); do
    c=${string:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9] ) o="$c" ;;
      * )               printf -v o '%%%02X' "'$c"
    esac
    encoded+="$o"
  done
  echo "$encoded"
}

script_exists() {
  curl --head --silent --fail "$1" > /dev/null
}

discover_resources() {
  resources=()
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  local tree_url="https://api.github.com/repos/$user/$repo/git/trees/$branch?recursive=1"
  local files=$(curl -s "$tree_url" | grep '"path":' | cut -d '"' -f4)

  while IFS= read -r path; do
    path=$(echo "$path" | tr -d '\r')
    if [[ "$path" == distros/$DISTRO/* && "$path" == *.sh && "$path" != *-check.sh ]]; then
      local relative="${path#distros/$DISTRO/}"
      local name="${relative%.sh}"
      [[ -n "$name" ]] && resources+=("$name")
    fi
  done <<< "$files"
}

show_resource_status() {
  local name="$1"
  local encoded_name=$(urlencode "$name")
  local install_script="$REPO_BASE/distros/$DISTRO/${encoded_name}.sh"
  local check_script="$REPO_BASE/distros/$DISTRO/${encoded_name}-check.sh"

  local has_install=false
  local has_check=false

  script_exists "$install_script" && has_install=true
  script_exists "$check_script" && has_check=true

  if [ "$has_install" = false ]; then
    echo "❌  " # Erro no script
    return
  fi

  if [ "$has_check" = false ]; then
    echo "  -" # Checagem ausente
    return
  fi

  if bash <(curl -sSL "$check_script"); then
    echo "[x]" # Checado e instalado
  else
    echo "[ ]" # Checado e não instalado
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
      menu_list+=("$status $name")
    fi
  done

  menu_list+=("   Sair")

  selected=$(
    printf "%s\n" "${menu_list[@]}" | fzf \
      --prompt="🔧 Pós-Instalação para $DISTRO. Use as setas para navegar e Enter para selecionar:" \
      --height=100% \
      --border \
      --layout=reverse
  )


  opcao=$(echo "$selected" | sed -E 's/^\s*(\[[x ]\]|❌|-) +//')
  

  if [[ "$opcao" == "Sair" ]]; then
    echo "👋 Saindo..."
    break
  fi

  encoded_name=$(urlencode "$opcao")
  install_script="$REPO_BASE/distros/$DISTRO/${encoded_name}.sh"

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
