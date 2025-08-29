#!/bin/bash

set -e

echo "🔍 Verificando componentes do sources.list..."

FILE="/etc/apt/sources.list"
TEMP="/tmp/sources.list.tmp"

# Faz backup antes de modificar
sudo cp "$FILE" "${FILE}.bak"

# Função para verificar e ajustar cada linha
adjust_line() {
  local line="$1"
  if [[ "$line" =~ ^deb ]]; then
    # Verifica se já contém os componentes
    if ! echo "$line" | grep -qE 'main.*contrib.*non-free.*non-free-firmware'; then
      # Adiciona os componentes ausentes
      echo "$line" | sed -E 's/main.*/main contrib non-free non-free-firmware/' >> "$TEMP"
    else
      echo "$line" >> "$TEMP"
    fi
  else
    echo "$line" >> "$TEMP"
  fi
}

# Processa linha por linha
> "$TEMP"
while IFS= read -r line; do
  adjust_line "$line"
done < "$FILE"

# Substitui o sources.list
sudo mv "$TEMP" "$FILE"

echo "✅ sources.list ajustado com sucesso!"
echo "🔄 Atualizando lista de pacotes..."
sudo apt update
sudo apt modernize-sources -y
