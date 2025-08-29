#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BASE="$REPO_BASE/distros/$DISTRO"

resources=()

script_exists() {
  curl --head --silent --fail "$1" > /dev/null
}

discover_resources() {
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  local index_url="https://api.github.com/repos/$user/$repo/contents/distros/$DISTRO?ref=$branch"
  local files=$(curl -s "$index_url" | grep '"name":' | cut -d '"' -f4)

  while IFS= read -r file; do
    file=$(echo "$file" | tr -d '\r')
    if [[ "$file" == *.sh && "$file" != *-check.sh ]]; then
      local name="${file%.sh}"
      if [[ -n "$name" ]]; then
        resources+=("$name")
      fi
    fi
  done <<< "$files"
}

show_resource_status() {
  local name="$1"
  local install_script="$BASE/${name}.sh"
  local check_script="$BASE/${name}-check.sh"

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

discover_resources

echo ""
echo "🔧 Menu de Pós-Instalação para $DISTRO"
echo "Use as setas para navegar e Enter para selecionar:"
echo ""

# Gera lista com status para exibir no fzf
menu_list=()
for name in "${resources[@]}"; do
  if [[ -n "$name" ]]; then
    status=$(show_resource_status "$name" | tail -n1)
    menu_list+=("$name - $status")
  fi
done

# Usa fzf para selecionar
selected=$(printf "%s\n" "${menu_list[@]}" | fzf --prompt="Selecione o recurso: " --height=20 --border)

# Extrai nome do recurso selecionado
opcao=$(echo "$selected" | cut -d' ' -f1)

install_script="$BASE/${opcao}.sh"
if script_exists "$install_script"; then
  echo ""
  echo "🔧 Instalando $opcao..."
  bash <(curl -sSL "$install_script")
else
  echo "❌ Opção inválida ou script não disponível."
fi
