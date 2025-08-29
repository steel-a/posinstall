#!/bin/bash

DISTRO="debian"
BASE_DIR="distros/$DISTRO"
CURRENT_PATH=""

show_menu() {
    clear
    echo "=== Menu de Instalação (${DISTRO}) ==="
    echo "Local: ${CURRENT_PATH:-raiz}"
    echo ""

    local full_path="$BASE_DIR/$CURRENT_PATH"

    # Mostrar apenas subpastas (sem scripts dentro delas)
    for dir in "$full_path"/*; do
        [ -d "$dir" ] && echo "$(basename "$dir")/"
    done

    # Mostrar apenas scripts .sh diretamente na pasta atual
    for file in "$full_path"/*.sh; do
        [ -f "$file" ] && echo "$(basename "$file" .sh)"
    done

    echo ""
    if [ -n "$CURRENT_PATH" ]; then
        echo "⬅️ Voltar"
    fi
    echo "❌ Sair"
}

read_choice() {
    echo ""
    read -p "Escolha uma opção: " choice

    local full_path="$BASE_DIR/$CURRENT_PATH"

    if [[ "$choice" == "❌" || "$choice" == "sair" ]]; then
        echo "Saindo..."
        exit 0
    elif [[ "$choice" == "⬅️" || "$choice" == "voltar" ]]; then
        CURRENT_PATH="$(dirname "$CURRENT_PATH")"
        [ "$CURRENT_PATH" == "." ] && CURRENT_PATH=""
    elif [ -d "$full_path/$choice" ]; then
        CURRENT_PATH="$CURRENT_PATH/$choice"
    elif [ -f "$full_path/$choice.sh" ]; then
        bash "$full_path/$choice.sh"
        read -p "Pressione Enter para voltar ao menu..."
    else
        echo "Opção inválida."
        sleep 1
    fi
}

while true; do
    show_menu
    read_choice
done
