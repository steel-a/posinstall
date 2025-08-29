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

  local path="distros/$DISTRO"
  [[ -n "$CURRENT_PATH" ]] && path="$path/$CURRENT_PATH"

  local index_url="https://api.github.com/repos/$user/$repo/contents/$path?ref=$branch"
  local response=$(curl -s "$index_url")

  # Processa cada item mantendo nome e tipo juntos
  echo "$response" | tr -d '\r' | awk '
    /"name":/ { name = $2; gsub(/"|,/, "", name) }
    /"type":/ {
      type = $2; gsub(/"|,/, "", type)
      if (type == "dir") {
        print "DIR:" name
      } else if (type == "file" && name ~ /\.sh$/ && name !~ /-check\.sh$/) {
        sub(/\.sh$/, "", name)
        print "SH:" name
      }
    }
  ' | while read -r entry; do
    if [[ "$entry" == DIR:* ]]; then
      folders+=("${entry#DIR:}")
    elif [[ "$entry" == SH:* ]]; then
      resources+=("${entry#SH:}")
    fi
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

  # Adiciona pastas
  for folder in "${folders[@]}"; do
    menu_list+=("$folder - 📁 Abrir pasta")
  done

  # Adiciona scripts
  for name in "${resources[@]}"; do
    if [[ -n "$name" ]]; then
      status=$(show_resource_status "$name" | tail -n1)
      menu_list+=("$name - $status")
    fi
  done

  # Opções de navegação
  [[ -n "$CURRENT_PATH" ]] && menu_list+=("Voltar - 🔙 Retornar à pasta anterior")
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
  elif [[ "$opcao" == "Voltar" ]]; then
    CURRENT_PATH=$(dirname "$CURRENT_PATH")
    [[ "$CURRENT_PATH" == "." ]] && CURRENT_PATH=""
  elif [[ " ${folders[*]} " =~ " $opcao " ]]; then
    CURRENT_PATH="${CURRENT_PATH}/${opcao}"
    CURRENT_PATH="${CURRENT_PATH#/}"
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
