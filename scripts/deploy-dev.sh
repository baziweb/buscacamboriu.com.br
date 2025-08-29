#!/bin/bash

# Script de deploy para desenvolvimento
# Uso: ./scripts/deploy-dev.sh

set -e

echo "🚀 Iniciando deploy para desenvolvimento..."

# Configurações
REMOTE_HOST="109.106.250.206"
REMOTE_USER="baziwebc"
REMOTE_PATH="/home/baziwebc/buscacamboriu.com.br"
LOCAL_PATH="."

# Função para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Validar se estamos na branch develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    log "⚠️  Aviso: Você não está na branch develop. Branch atual: $CURRENT_BRANCH"
    read -p "Deseja continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Criar arquivo temporário excluindo arquivos desnecessários
log "📦 Criando pacote de deploy..."
tar -czf /tmp/deploy-dev.tar.gz \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.env' \
    --exclude='wp-config.php' \
    --exclude='scripts' \
    .

# Upload do arquivo
log "📤 Enviando arquivos para o servidor..."
scp /tmp/deploy-dev.tar.gz $REMOTE_USER@$REMOTE_HOST:/tmp/

# Executar deploy no servidor
log "🔧 Executando deploy no servidor..."
ssh $REMOTE_USER@$REMOTE_HOST << 'EOF'
    cd /home/baziwebc/buscacamboriu.com.br
    
    # Backup dos arquivos atuais
    if [ -d "backup-dev" ]; then
        rm -rf backup-dev-old
        mv backup-dev backup-dev-old
    fi
    mkdir -p backup-dev
    cp -r * backup-dev/ 2>/dev/null || true
    
    # Extrair novos arquivos
    tar -xzf /tmp/deploy-dev.tar.gz
    rm /tmp/deploy-dev.tar.gz
    
    # Configurar permissões
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod 600 wp-config.php 2>/dev/null || true
    
    echo "✅ Deploy para desenvolvimento concluído!"
EOF

# Limpar arquivo temporário
rm -f /tmp/deploy-dev.tar.gz

log "🎉 Deploy concluído com sucesso!"
log "🌐 Site disponível em: http://buscacamboriu.com.br"
