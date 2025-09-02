#!/bin/bash

# Script de deploy para produção
# Uso: ./scripts/deploy-prod.sh

set -e

echo "🚀 Iniciando deploy para PRODUÇÃO..."

# Configurações
REMOTE_HOST="cpl27.main-hosting.eu"
REMOTE_USER="baziwebc"
REMOTE_PATH="/home/baziwebc/buscacamboriu.com.br"
LOCAL_PATH="."

# Função para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Validar se estamos na branch main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log "❌ ERRO: Deploy de produção só pode ser feito na branch main!"
    log "Branch atual: $CURRENT_BRANCH"
    exit 1
fi

# Confirmar deploy de produção
log "⚠️  ATENÇÃO: Você está prestes a fazer deploy em PRODUÇÃO!"
read -p "Tem certeza que deseja continuar? Digite 'DEPLOY' para confirmar: " -r
if [ "$REPLY" != "DEPLOY" ]; then
    log "❌ Deploy cancelado."
    exit 1
fi

# Verificar se há mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    log "❌ ERRO: Há mudanças não commitadas. Commit ou stash antes do deploy."
    exit 1
fi

# Criar arquivo temporário excluindo arquivos desnecessários
log "📦 Criando pacote de deploy..."
tar -czf /tmp/deploy-prod.tar.gz \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.env' \
    --exclude='wp-config.php' \
    --exclude='scripts' \
    --exclude='README.md' \
    .

# Upload do arquivo
log "📤 Enviando arquivos para o servidor..."
scp -P 65002 /tmp/deploy-prod.tar.gz $REMOTE_USER@$REMOTE_HOST:/tmp/

# Executar deploy no servidor com modo manutenção
log "🔧 Executando deploy no servidor..."
ssh -p 65002 $REMOTE_USER@$REMOTE_HOST << 'EOF'
    cd /home/baziwebc/buscacamboriu.com.br
    
    # Ativar modo manutenção
    echo "<?php \$upgrading = time(); ?>" > .maintenance
    echo "🔧 Modo manutenção ativado"
    
    # Backup completo com timestamp
    BACKUP_DIR="backups/prod-$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    cp -r * $BACKUP_DIR/ 2>/dev/null || true
    echo "📦 Backup criado em: $BACKUP_DIR"
    
    # Manter apenas os 5 backups mais recentes
    cd backups
    ls -dt prod-* | tail -n +6 | xargs rm -rf 2>/dev/null || true
    cd ..
    
    # Extrair novos arquivos
    tar -xzf /tmp/deploy-prod.tar.gz
    rm /tmp/deploy-prod.tar.gz
    
    # Configurar permissões
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod 600 wp-config.php 2>/dev/null || true
    
    # Limpar cache se existir
    if [ -d "wp-content/cache" ]; then
        rm -rf wp-content/cache/*
        echo "🗑️  Cache limpo"
    fi
    
    # Desativar modo manutenção
    rm -f .maintenance
    echo "✅ Modo manutenção desativado"
    
    echo "🎉 Deploy para produção concluído!"
EOF

# Limpar arquivo temporário
rm -f /tmp/deploy-prod.tar.gz

log "🎉 Deploy de produção concluído com sucesso!"
log "🌐 Site disponível em: https://buscacamboriu.com.br"

# Criar tag de release
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TAG_NAME="prod-$TIMESTAMP"
git tag -a $TAG_NAME -m "Deploy de produção: $TIMESTAMP"
log "🏷️  Tag criada: $TAG_NAME"
log "💡 Para enviar a tag: git push origin $TAG_NAME"
