#!/bin/bash

sudo apt modernize-sources -y 2>/dev/null || true

# Componentes obrigatórios
REQUIRED_COMPONENTS=("main" "contrib" "non-free" "non-free-firmware")

# Diretório dos sources modernos
SOURCE_DIR="/etc/apt/sources.list.d"

# Processa todos os arquivos .sources
for file in "$SOURCE_DIR"/*.sources; do
    echo "🔍 Verificando: $file"

    # Cria backup antes de modificar
    sudo cp "$file" "$file.bak"

    # Para cada linha que começa com Components:
    while IFS= read -r line; do
        if [[ "$line" =~ ^Components: ]]; then
            # Extrai os componentes atuais
            current_components=($line)
            unset current_components[0]  # Remove "Components:"

            # Monta nova linha com componentes faltantes
            new_line="Components:"
            for comp in "${REQUIRED_COMPONENTS[@]}"; do
                if [[ " ${current_components[@]} " =~ " $comp " ]]; then
                    new_line+=" $comp"
                else
                    echo "➕ Adicionando '$comp' ao linha de $file"
                    new_line+=" $comp"
                fi
            done

            # Escapa a linha original para uso no sed
            escaped_line=$(echo "$line" | sed 's/[&/\]/\\&/g')

            # Substitui a linha no arquivo
            sudo sed -i "s/^$escaped_line\$/$new_line/" "$file"
        fi
    done < "$file"
done

sudo apt update && sudo apt upgrade -y
echo "✅ Verificação concluída. Backups criados com extensão .bak"
