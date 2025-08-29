#!/bin/bash

REPO_BASE="https://raw.githubusercontent.com/steel-a/posinstall/main"
DEPENDENCIAS=(bash curl fzf grep cut tr sed printf)

faltando=()
for cmd in "${DEPENDENCIAS[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    faltando+=("$cmd")
  fi
done

if [ ${#faltando[@]} -gt 0 ]; then
  echo "❌ Dependências ausentes:"
  for cmd in "${faltando[@]}"; do
    echo "   - $cmd"
  done
  exit 1
fi

# ❌ Verifica se está sendo executado como root
if [ "$EUID" -eq 0 ]; then
  echo "⚠️ Este script deve ser executado como usuário comum, não como root."
  exit 1
fi

# 🔐 Solicita autenticação sudo
echo "🔐 Verificando permissões sudo..."
sudo -v || { echo "❌ Permissões sudo não concedidas."; exit 1; }

# ⏳ Mantém o timestamp sudo ativo em segundo plano
( while true; do sudo -v; sleep 60; done ) &
SUDO_LOOP_PID=$!

# 🧭 Detecta a distribuição
DETECT_SCRIPT=$(curl -fsSL "$REPO_BASE/utils/detect_distro.sh")
if [ $? -ne 0 ] || [ -z "$DETECT_SCRIPT" ]; then
  echo "❌ Erro ao baixar o script de detecção de distribuição."
  kill "$SUDO_LOOP_PID" 2>/dev/null
  exit 1
fi
DISTRO=$(bash <(echo "$DETECT_SCRIPT"))
echo "🧭 Distribuição detectada: $DISTRO"

# 📋 Executa o menu correspondente
MENU_SCRIPT=$(curl -fsSL "$REPO_BASE/menu.sh")
if [ $? -ne 0 ] || [ -z "$MENU_SCRIPT" ]; then
  echo "❌ Erro ao baixar o script do menu."
  kill "$SUDO_LOOP_PID" 2>/dev/null
  exit 1
fi
bash <(echo "$MENU_SCRIPT") "$DISTRO" "$REPO_BASE"

# 🧹 Finaliza o processo de manutenção do sudo
kill "$SUDO_LOOP_PID" 2>/dev/null
