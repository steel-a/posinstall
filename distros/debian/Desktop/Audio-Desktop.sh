#!/bin/bash

set -e

echo "🔧 Atualizando lista de pacotes..."
sudo apt update

echo "📦 Instalando pacotes essenciais para o i3..."
packages=(
  pavucontrol pulsemixer pamixer pipewire-audio
)

sudo apt install -y "${packages[@]}"


echo "✅ Instalação concluída!"
