#!/bin/bash

# Script de configuração inicial do projeto
# Uso: ./scripts/setup.sh

set -e

echo "🚀 Configurando projeto Busca Camboriú..."

# Função para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    log "❌ Execute este script no diretório raiz do projeto"
    exit 1
fi

# Instalar dependências do Composer
if command -v composer &> /dev/null; then
    log "📦 Instalando dependências do Composer..."
    composer install --no-dev --optimize-autoloader
else
    log "⚠️  Composer não encontrado. Instalando..."
    # Instalar Composer
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer 2>/dev/null || sudo mv composer.phar /usr/local/bin/composer
    
    log "📦 Instalando dependências do Composer..."
    composer install --no-dev --optimize-autoloader
fi

# Configurar arquivo de ambiente
if [ ! -f ".env" ]; then
    log "⚙️  Criando arquivo de ambiente..."
    cp .env.example .env
    log "✏️  Configure o arquivo .env com suas credenciais"
fi

# Verificar conexão com servidor
log "🔗 Testando conectividade com servidor..."
if ./scripts/check-server.sh; then
    log "✅ Servidor configurado corretamente"
else
    log "⚠️  Problemas de conectividade. Verifique sua configuração SSH"
fi

# Configurar Git hooks (se necessário)
if [ -d ".git" ]; then
    log "🔧 Configurando Git..."
    
    # Configurar branch padrão como main
    git config init.defaultBranch main 2>/dev/null || true
    
    # Criar branches se não existirem
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    
    if [ "$CURRENT_BRANCH" = "main" ]; then
        # Criar branch develop se não existir
        if ! git show-ref --verify --quiet refs/heads/develop; then
            log "🌿 Criando branch develop..."
            git checkout -b develop
            git checkout main
        fi
    fi
    
    log "✅ Git configurado"
fi

# Verificar estrutura de diretórios
log "📁 Verificando estrutura de diretórios..."
directories=(
    "wp-content/themes"
    "wp-content/plugins"
    "wp-content/uploads"
    "scripts"
    ".github/workflows"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        log "📂 Criando diretório: $dir"
        mkdir -p "$dir"
    fi
done

# Verificar permissões dos scripts
log "🔒 Configurando permissões..."
chmod +x scripts/*.sh

# Criar estrutura de logs
mkdir -p logs

# Informações finais
log "🎉 Configuração inicial concluída!"

echo
echo "📋 Próximos passos:"
echo
echo "1. 🔑 Configure sua chave SSH:"
echo "   ssh-keygen -t ed25519 -C 'deploy-buscacamboriu'"
echo "   ssh-copy-id -p 65002 baziwebc@cpl27.main-hosting.eu"
echo
echo "2. 🔒 Configure os secrets no GitHub:"
echo "   - SSH_PRIVATE_KEY (conteúdo da chave privada)"
echo "   - SSH_USER: baziwebc"
echo "   - HOST: cpl27.main-hosting.eu"
echo
echo "3. 🌍 Configure os environments no GitHub:"
echo "   - production (protegida com branch main)"
echo "   - development"
echo
echo "4. 📝 Configure o arquivo .env com suas credenciais"
echo
echo "5. 🚀 Faça seu primeiro commit:"
echo "   git add ."
echo "   git commit -m 'feat: configuração inicial do deploy'"
echo "   git push origin main"
echo
echo "✅ Sistema pronto para uso!"
