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
  # Extrai partes da URL
  local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
  local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
  local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)

  # Monta URL da API
  local index_url="https://api.github.com/repos/$user/$repo/contents/distros/$DISTRO?ref=$branch"

  # Obtém lista de arquivos
  local files=$(curl -s "$index_url" | grep '"name":' | cut -d '"' -f4)

  # Adiciona apenas scripts que não terminam com -check.sh
  for file in $files; do
    if [[ "$file" =~ ^(.+)\.sh$ && ! "$file" =~ -check\.sh$ ]]; then
      local name="${BASH_REMATCH[1]}"
      resources+=("$name")
    fi
  done
}





# Função para exibir status de cada recurso
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
