#!/bin/bash

DISTRO="$1"
REPO_BASE="$2"
BASE="$REPO_BASE/distros/$DISTRO"

script_exists() {
    curl --head --silent --fail "$1" > /dev/null
}

discover_resources() {
    resources=()
    local user=$(echo "$REPO_BASE" | cut -d'/' -f4)
    local repo=$(echo "$REPO_BASE" | cut -d'/' -f5)
    local branch=$(echo "$REPO_BASE" | cut -d'/' -f6)
    local api_url="https://api.github.com/repos/$user/$repo/contents/distros/$DISTRO?ref=$branch"

    # Função recursiva para explorar subpastas
    fetch_scripts_recursively() {
        local url="$1"
        local path="$2"
        local response=$(curl -s "$url")
    
        # Extrai blocos de arquivos e diretórios
        echo "$response" | tr -d '\n' | sed 's/},{/}\n{/g' | while read -r item; do
            local type=$(echo "$item" | grep -o '"type":"[^"]*"' | cut -d'"' -f4)
            local name=$(echo "$item" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
            local full_path="$path/$name"
    
            if [[ "$type" == "dir" ]]; then
                local suburl="https://api.github.com/repos/$user/$repo/contents/$full_path?ref=$branch"
                fetch_scripts_recursively "$suburl" "$full_path"
            elif [[ "$type" == "file" && "$name" == *.sh && "$name" != *-check.sh ]]; then
                local script_name="${full_path%.sh}"
                resources+=("$script_name")
            fi
        done
    }


    fetch_scripts_recursively "$api_url" "distros/$DISTRO"
}

show_resource_status() {
    local name="$1"
    local install_script="$REPO_BASE/${name}.sh"
    local check_script="$REPO_BASE/${name}-check.sh"
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

    selected=$( printf "%s\n" "${menu_list[@]}" | fzf \
        --prompt="🔧 Pós-Instalação para $DISTRO. Use as setas para navegar e Enter para selecionar:" \
        --height=100% \
        --border \
        --layout=reverse )

    opcao=$(echo "$selected" | cut -d' ' -f1)

    if [[ "$opcao" == "Sair" ]]; then
        echo "👋 Saindo..."
        break
    fi

    install_script="$REPO_BASE/${opcao}.sh"

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
