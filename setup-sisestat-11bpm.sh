#!/bin/bash

# ============================================================================
# GUIA COMPLETO: Sincronizar SisEstat 11 BPM com GitHub
# ============================================================================
# Este script automatiza todo o processo de sincronização
# Copie e execute linha por linha no seu terminal
# ============================================================================

echo "🚀 Iniciando sincronização do SisEstat 11 BPM com GitHub..."
echo ""

# ============================================================================
# ETAPA 1: Navegue até o diretório do projeto
# ============================================================================
echo "📁 ETAPA 1: Acessando diretório do projeto..."
cd "G:\Meu Drive\projeto estatistica"
echo "✅ Pronto! Você está em: $(pwd)"
echo ""

# ============================================================================
# ETAPA 2: Criar .gitignore
# ============================================================================
echo "📝 ETAPA 2: Criando arquivo .gitignore..."

cat > .gitignore << 'EOF'
# Environment files
.env
.env.local
.env.*.local
.env.production
.env.development

# Database files
*.db
*.sqlite
*.sqlite3
*.sqlite-journal

# Excel and data files
*.xlsx
*.xls
*.csv
*.tsv

# Backup files
backups/
backup/
*.bak
*.backup
*~
.#*

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
venv/
ENV/
env/
.venv

# IDE
.vscode/
.idea/
*.swp
*.swo
*.sublime-project
*.sublime-workspace
.DS_Store
Thumbs.db
*.iml
.classpath
.project
.settings/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Node.js
node_modules/
package-lock.json
yarn.lock

# OS
.DS_Store
.AppleDouble
.LSOverride
$RECYCLE.BIN/
.Spotlight-V100
.Trashes

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/

# Temporary
*.tmp
*.temp
.cache/
EOF

echo "✅ .gitignore criado com sucesso!"
echo ""

# ============================================================================
# ETAPA 3: Inicializar repositório Git
# ============================================================================
echo "🔧 ETAPA 3: Inicializando repositório Git..."
git init
echo "✅ Repositório Git inicializado!"
echo ""

# ============================================================================
# ETAPA 4: Configurar usuário Git (local)
# ============================================================================
echo "👤 ETAPA 4: Configurando usuário Git..."
git config user.name "Dayvison Cabral"
git config user.email "dayvison.ufpe2015@gmail.com"
echo "✅ Usuário Git configurado!"
echo ""

# ============================================================================
# ETAPA 5: Adicionar arquivos
# ============================================================================
echo "📦 ETAPA 5: Adicionando arquivos ao Git..."
git add .
echo "✅ Arquivos adicionados!"
echo ""

# ============================================================================
# ETAPA 6: Verificar status
# ============================================================================
echo "🔍 ETAPA 6: Verificando status..."
echo ""
echo "Verifique abaixo se .env, *.db, backups/ e *.xlsx NÃO aparecem:"
echo "───────────────────────────────────────────────────────────"
git status
echo "───────────────────────────────────────────────────────────"
echo ""
read -p "Os arquivos sensíveis foram excluídos? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Verifique o .gitignore e tente novamente!"
    exit 1
fi
echo ""

# ============================================================================
# ETAPA 7: Fazer commit inicial
# ============================================================================
echo "💾 ETAPA 7: Fazendo commit inicial..."
git commit -m "Importação inicial do SisEstat 11 BPM"
echo "✅ Commit realizado!"
echo ""

# ============================================================================
# ETAPA 8: Renomear branch para 'main'
# ============================================================================
echo "🌿 ETAPA 8: Renomeando branch para 'main'..."
git branch -M main
echo "✅ Branch renomeado para 'main'!"
echo ""

# ============================================================================
# ETAPA 9: Autenticar no GitHub
# ============================================================================
echo "🔐 ETAPA 9: Autenticando no GitHub..."
echo "Você será redirecionado para autenticar. Siga as instruções na tela."
gh auth login
echo "✅ Autenticação realizada!"
echo ""

# ============================================================================
# ETAPA 10: Criar repositório privado no GitHub
# ============================================================================
echo "📡 ETAPA 10: Criando repositório privado no GitHub..."
gh repo create sisestat-11bpm --private --source=. --push
echo "✅ Repositório criado e sincronizado!"
echo ""

# ============================================================================
# ETAPA 11: Verificar resultado
# ============================================================================
echo "🎉 ETAPA 11: Verificando resultado final..."
echo ""
echo "📋 Histórico de commits:"
git log --oneline
echo ""
echo "🔗 Remote configurado:"
git remote -v
echo ""

# ============================================================================
# RESUMO FINAL
# ============================================================================
echo "════════════════════════════════════════════════════════════"
echo "✅ SINCRONIZAÇÃO CONCLUÍDA COM SUCESSO!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Seu projeto SisEstat 11 BPM está agora no GitHub!"
echo ""
echo "Próximas vezes, para sincronizar mudanças:"
echo "  1. git add ."
echo "  2. git commit -m \"Descrição das mudanças\""
echo "  3. git push"
echo ""
echo "Ou execute os scripts de sincronização:"
echo "  bash sync-opencode-github.sh ./projeto https://github.com/usuario/repo.git"
echo "  python3 sync-opencode-github.py ./projeto https://github.com/usuario/repo.git"
echo ""
