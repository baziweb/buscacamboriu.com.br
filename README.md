# Busca Camboriú - Sistema de Deploy

Este repositório contém o código do site Busca Camboriú com sistema de deploy automático via GitHub Actions.

## 🏗️ Estrutura de Branches

- **`main`**: Branch de produção - deploys automáticos para o servidor principal
- **`develop`**: Branch de desenvolvimento - para testes e desenvolvimento

## 🚀 Sistema de Deploy

### Deploy Automático (GitHub Actions)

O deploy é executado automaticamente quando:
- Push na branch `main` → Deploy em produção
- Push na branch `develop` → Deploy em desenvolvimento
- Pull Requests → Validação e testes

### Deploy Manual

Você também pode fazer deploy manual usando os scripts:

```bash
# Deploy para desenvolvimento (branch develop)
./scripts/deploy-dev.sh

# Deploy para produção (branch main)
./scripts/deploy-prod.sh
```

## ⚙️ Configuração Inicial

### 1. Configurar Secrets no GitHub

Acesse `Settings > Secrets and variables > Actions` e adicione:

```
SSH_PRIVATE_KEY: Sua chave SSH privada
SSH_USER: baziwebc
HOST: cpl27.main-hosting.eu
```

**⚠️ Importante:** O servidor usa a porta SSH customizada **65002**. Certifique-se de configurar sua chave SSH corretamente.

### 2. Gerar e Configurar Chave SSH

```bash
# No seu computador local, gere uma chave SSH
ssh-keygen -t ed25519 -C "deploy-buscacamboriu"

# Copie a chave pública para o servidor
ssh-copy-id -p 65002 baziwebc@cpl27.main-hosting.eu

# Adicione a chave privada nos secrets do GitHub
cat ~/.ssh/id_ed25519 # Cole este conteúdo no secret SSH_PRIVATE_KEY
```

### 3. Configurar Environments no GitHub

1. Acesse `Settings > Environments`
2. Crie dois ambientes:
   - `production` (com proteção de branch main)
   - `development`

## 📁 Estrutura do Servidor

```
/home/baziwebc/buscacamboriu.com.br/
├── wp-content/
├── wp-config.php
├── backups/          # Backups automáticos
├── backup-dev/       # Backup de desenvolvimento
└── ...arquivos do WordPress
```

## 🔄 Fluxo de Trabalho

### Desenvolvimento
1. Crie uma feature branch a partir de `develop`
2. Desenvolva sua funcionalidade
3. Abra um Pull Request para `develop`
4. Após aprovação, merge → Deploy automático para desenvolvimento

### Produção
1. Abra um Pull Request de `develop` para `main`
2. Após revisão e testes, faça o merge
3. Deploy automático para produção

## 🛡️ Segurança

- Backup automático antes de cada deploy
- Modo manutenção durante deploy de produção
- Validação de sintaxe PHP
- Exclusão de arquivos sensíveis no deploy
- Permissões corretas após deploy

## 📊 Monitoramento

### Logs de Deploy
Os logs ficam disponíveis na aba "Actions" do GitHub.

### Verificação de Status
```bash
# Verificar status do servidor
ssh -p 65002 baziwebc@cpl27.main-hosting.eu 'cd /home/baziwebc/buscacamboriu.com.br && ls -la'

# Verificar logs de erro do WordPress
ssh -p 65002 baziwebc@cpl27.main-hosting.eu 'tail -f /home/baziwebc/buscacamboriu.com.br/wp-content/debug.log'
```

## 🔧 Scripts Disponíveis

- `scripts/deploy-dev.sh`: Deploy manual para desenvolvimento
- `scripts/deploy-prod.sh`: Deploy manual para produção

## 📝 Notas Importantes

1. **wp-config.php** nunca é sobrescrito no deploy
2. Backups são mantidos por 5 versões em produção
3. Cache é limpo automaticamente após deploy
4. Deploy de produção requer confirmação manual
5. Tags automáticas são criadas para releases de produção

## 🆘 Troubleshooting

### Deploy falhou?
1. Verifique os logs na aba Actions
2. Confirme se as secrets estão configuradas
3. Teste conexão SSH manualmente

### Site em manutenção?
```bash
# Remover modo manutenção manualmente
ssh -p 65002 baziwebc@cpl27.main-hosting.eu 'rm -f /home/baziwebc/buscacamboriu.com.br/.maintenance'
```

### Restaurar backup?
```bash
# Listar backups disponíveis
ssh -p 65002 baziwebc@cpl27.main-hosting.eu 'ls -la /home/baziwebc/buscacamboriu.com.br/backups/'

# Restaurar backup específico
ssh -p 65002 baziwebc@cpl27.main-hosting.eu 'cd /home/baziwebc/buscacamboriu.com.br && cp -r backups/prod-YYYYMMDD_HHMMSS/* .'
```

## 🌐 URLs

- **Produção**: https://buscacamboriu.com.br
- **Desenvolvimento**: https://buscacamboriu.com.br (mesmo servidor)

---

**Desenvolvido com ❤️ para Busca Camboriú**
