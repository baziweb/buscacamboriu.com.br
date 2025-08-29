#!/bin/bash

# Script de verificação de conectividade e configuração
# Uso: ./scripts/check-server.sh

echo "🔍 Verificando conectividade com o servidor..."

# Configurações
REMOTE_HOST="109.106.250.206"
REMOTE_USER="baziwebc"
REMOTE_PATH="/home/baziwebc/buscacamboriu.com.br"

# Função para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Verificar se consegue conectar via SSH
log "🔗 Testando conexão SSH..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes $REMOTE_USER@$REMOTE_HOST exit; then
    log "✅ Conexão SSH bem-sucedida"
else
    log "❌ Falha na conexão SSH"
    log "💡 Certifique-se de que:"
    log "   - Sua chave SSH está configurada"
    log "   - O usuário $REMOTE_USER tem acesso"
    log "   - O servidor $REMOTE_HOST está acessível"
    exit 1
fi

# Verificar diretório no servidor
log "📁 Verificando diretório do projeto..."
ssh $REMOTE_USER@$REMOTE_HOST << EOF
    if [ -d "$REMOTE_PATH" ]; then
        echo "✅ Diretório existe: $REMOTE_PATH"
        echo "📊 Conteúdo do diretório:"
        ls -la $REMOTE_PATH | head -10
        echo "..."
        
        # Verificar permissões
        PERMS=\$(stat -c %a $REMOTE_PATH)
        echo "🔒 Permissões do diretório: \$PERMS"
        
        # Verificar espaço em disco
        echo "💾 Espaço em disco:"
        df -h $REMOTE_PATH
        
    else
        echo "❌ Diretório não existe: $REMOTE_PATH"
        echo "💡 Execute: mkdir -p $REMOTE_PATH"
        exit 1
    fi
EOF

log "🎉 Verificação concluída!"
log "🚀 Sistema pronto para deploy!"

echo
echo "📋 Próximos passos:"
echo "1. Configure os secrets no GitHub (SSH_PRIVATE_KEY, SSH_USER, HOST)"
echo "2. Configure os environments (production, development)"
echo "3. Faça seu primeiro commit e push"
echo "4. O deploy será executado automaticamente!"
