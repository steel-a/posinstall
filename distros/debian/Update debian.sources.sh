#!/bin/bash

sudo apt modernize-sources -y

#!/bin/bash

# Componentes obrigatórios
REQUIRED_COMPONENTS=("main" "contrib" "non-free" "non-free-firmware")

# Diretório dos sources modernos
SOURCE_DIR="/etc/apt/sources.list.d"

# Processa todos os arquivos .sources
for file in "$SOURCE_DIR"/*.sources; do
    echo "🔍 Verificando: $file"

    # Cria backup antes de modificar
    sudo cp "$file" "$file.bak"

    # Extrai linhas de Components
    while IFS= read -r line; do
        if [[ "$line" =~ ^Components: ]]; then
            current_components=($line)
            # Remove "Components:" da primeira posição
            unset current_components[0]

            # Verifica e adiciona componentes faltantes
            for comp in "${REQUIRED_COMPONENTS[@]}"; do
                if [[ ! " ${current_components[@]} " =~ " $comp " ]]; then
                    echo "➕ Adicionando '$comp' ao arquivo $file"
                    sudo sed -i "/^Components:/ s/$/ $comp/" "$file"
                fi
            done
        fi
    done < "$file"
done

echo "✅ Verificação concluída. Backups criados com extensão .bak"
