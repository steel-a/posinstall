#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BASE="$REPO_BASE/distros/$DISTRO"

# Lista de recursos detectados
resources=()

# Função para verificar se um script existe
script_exists() {
  curl --head --silent --fail "$1" > /dev/null
}

# Função para extrair nomes de recursos válidos
discover_resources() {
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  local index_url="https://api.github.com/repos/$user/$repo/contents/distros/$DISTRO?ref=$branch"

  local files=$(curl -s "$index_url" | grep '"name":' | cut -d '"' -f4)

  for file in $files; do
    # Ignora arquivos -check.sh
    if [[ "$file" =~ ^(.+)\.sh$ && ! "$file" =~ -check\.sh$ ]]; then
      local name="${file%.sh}"  # Remove a extensão .sh com segurança
      resources+=("$name")
    fi
  done
}






# Função para exibir status de cada recurso
show_resource_status() {
  local name="$1"
  if [[ -z "$name" ]]; then
    return
  fi  
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
    echo "🟡 $name [disponível para instalar]"
    return
  fi

  local status=$(bash <(curl -sSL "$check_script"))
  if [[ "$status" == "🟢" ]]; then
    echo "🟢 $name [instalado]"
  else
    echo "🟡 $name [disponível para instalar]"
  fi
}


# Descobre recursos
discover_resources

# Exibe menu
echo ""
echo "🔧 Menu de Pós-Instalação para $DISTRO"
for name in "${resources[@]}"; do
  show_resource_status "$name"
done
echo ""

# Lê escolha
read -p "Escolha uma opção para instalar: " opcao

install_script="$BASE/${opcao}.sh"
if script_exists "$install_script"; then
  bash <(curl -sSL "$install_script")
else
  echo "❌ Opção inválida ou script não disponível."
fi
