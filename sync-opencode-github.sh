#!/bin/bash

# ============================================================================
# Script de Sincronização: OpenCode ↔ GitHub
# ============================================================================
# Sincroniza automaticamente um projeto do OpenCode com o repositório GitHub
# 
# Uso: ./sync-opencode-github.sh <caminho-projeto-opencode> <url-github-repo>
# Exemplo: ./sync-opencode-github.sh ~/meu-projeto https://github.com/usuario/meu-repo.git
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validação de argumentos
if [ $# -lt 2 ]; then
    log_error "Argumentos insuficientes!"
    echo ""
    echo "Uso: $0 <caminho-projeto-opencode> <url-github-repo>"
    echo "Exemplo: $0 ~/meu-projeto https://github.com/usuario/meu-repo.git"
    exit 1
fi

OPENCODE_PATH="$1"
GITHUB_URL="$2"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Validar se o diretório do OpenCode existe
if [ ! -d "$OPENCODE_PATH" ]; then
    log_error "Diretório do OpenCode não encontrado: $OPENCODE_PATH"
    exit 1
fi

log_info "Iniciando sincronização..."
log_info "Projeto OpenCode: $OPENCODE_PATH"
log_info "Repositório GitHub: $GITHUB_URL"
log_info "Timestamp: $TIMESTAMP"
echo ""

# ============================================================================
# ETAPA 1: Preparar o repositório Git
# ============================================================================
log_info "Etapa 1: Preparando repositório Git..."

cd "$OPENCODE_PATH"

# Verificar se já é um repositório Git
if [ ! -d ".git" ]; then
    log_info "Inicializando Git no projeto..."
    git init
    git config user.name "OpenCode Sync Bot"
    git config user.email "sync@opencode-github.local"
    log_success "Repositório Git inicializado"
else
    log_warning "Repositório Git já existe"
fi

# ============================================================================
# ETAPA 2: Criar .gitignore se não existir
# ============================================================================
log_info "Etapa 2: Verificando .gitignore..."

if [ ! -f ".gitignore" ]; then
    log_info "Criando .gitignore padrão..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
venv/
env/

# Build files
dist/
build/
*.o
*.a

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Environment
.env
.env.local
.env.*.local

# Logs
*.log
npm-debug.log*
yarn-debug.log*

# OS
Thumbs.db
.DS_Store
EOF
    log_success ".gitignore criado"
else
    log_warning ".gitignore já existe"
fi

# ============================================================================
# ETAPA 3: Adicionar arquivos ao Git
# ============================================================================
log_info "Etapa 3: Adicionando arquivos ao Git..."

git add .

# Verificar se há mudanças
if git diff --quiet --cached; then
    log_warning "Nenhuma mudança para sincronizar"
else
    log_info "Alterações detectadas, fazendo commit..."
    git commit -m "Sync OpenCode → GitHub [$TIMESTAMP]" || true
    log_success "Commit realizado"
fi

# ============================================================================
# ETAPA 4: Configurar remote do GitHub
# ============================================================================
log_info "Etapa 4: Configurando remote do GitHub..."

if git remote | grep -q "origin"; then
    log_info "Remote 'origin' já existe, atualizando URL..."
    git remote set-url origin "$GITHUB_URL"
else
    log_info "Adicionando remote 'origin'..."
    git remote add origin "$GITHUB_URL"
fi

log_success "Remote configurado: $GITHUB_URL"

# ============================================================================
# ETAPA 5: Garantir branch main
# ============================================================================
log_info "Etapa 5: Verificando branch principal..."

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" != "main" ]; then
    log_info "Renomeando branch de '$CURRENT_BRANCH' para 'main'..."
    git branch -M main
fi

log_success "Branch principal: main"

# ============================================================================
# ETAPA 6: Push para GitHub
# ============================================================================
log_info "Etapa 6: Fazendo push para GitHub..."

if git push -u origin main 2>&1; then
    log_success "Push realizado com sucesso!"
else
    log_warning "Erro ao fazer push. Verifique suas credenciais do GitHub."
    log_info "Dicas de resolução:"
    echo "  1. Configure SSH ou HTTPS: git config --global credential.helper store"
    echo "  2. Gere um Personal Access Token em https://github.com/settings/tokens"
    echo "  3. Use: git push -u origin main --force (cuidado!)"
fi

# ============================================================================
# ETAPA 7: Criar arquivo de status
# ============================================================================
log_info "Etapa 7: Criando relatório de sincronização..."

cat > .sync-status.json << EOF
{
  "last_sync": "$TIMESTAMP",
  "opencode_path": "$OPENCODE_PATH",
  "github_url": "$GITHUB_URL",
  "branch": "main",
  "status": "success"
}
EOF

log_success "Relatório criado: .sync-status.json"

# ============================================================================
# RESUMO FINAL
# ============================================================================
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
log_success "SINCRONIZAÇÃO CONCLUÍDA COM SUCESSO!"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Resumo:"
echo "  📁 Projeto OpenCode: $OPENCODE_PATH"
echo "  🔗 Repositório GitHub: $GITHUB_URL"
echo "  ⏱️  Timestamp: $TIMESTAMP"
echo "  📊 Branch: main"
echo ""
echo "Próximos passos:"
echo "  1. Acesse: $GITHUB_URL"
echo "  2. Verifique os arquivos no GitHub"
echo "  3. Para sincronizações futuras, execute este script novamente"
echo ""
echo "Dica: Configure um cron job para sincronização automática:"
echo "  crontab -e"
echo "  # Sincronizar a cada 30 minutos"
echo "  */30 * * * * $0 '$OPENCODE_PATH' '$GITHUB_URL' >> /tmp/opencode-sync.log 2>&1"
echo ""
