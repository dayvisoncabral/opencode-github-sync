#!/usr/bin/env python3

"""
================================================================================
Script de Sincronização: OpenCode ↔ GitHub (Versão Python)
================================================================================
Sincroniza automaticamente um projeto do OpenCode com o repositório GitHub.
Versão portável (funciona em Windows, macOS e Linux)

Uso: python3 sync-opencode-github.py <caminho-projeto> <url-github>
Exemplo: python3 sync-opencode-github.py ~/meu-projeto https://github.com/usuario/meu-repo.git
================================================================================
"""

import os
import sys
import subprocess
import json
from datetime import datetime
from pathlib import Path

# ============================================================================
# Cores para terminal
# ============================================================================
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

# ============================================================================
# Funções de logging
# ============================================================================
def log_info(message):
    print(f"{Colors.BLUE}[INFO]{Colors.ENDC} {message}")

def log_success(message):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.ENDC} {message}")

def log_warning(message):
    print(f"{Colors.YELLOW}[WARNING]{Colors.ENDC} {message}")

def log_error(message):
    print(f"{Colors.RED}[ERROR]{Colors.ENDC} {message}")

def run_command(command, cwd=None, check=True):
    """Executa um comando shell e retorna o resultado"""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            shell=True,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        log_error(f"Erro ao executar comando: {str(e)}")
        return False, "", str(e)

# ============================================================================
# ETAPA 1: Validar argumentos e diretórios
# ============================================================================
def validate_inputs(opencode_path, github_url):
    """Valida os argumentos de entrada"""
    log_info("Etapa 1: Validando argumentos...")
    
    # Validar diretório
    if not os.path.isdir(opencode_path):
        log_error(f"Diretório não encontrado: {opencode_path}")
        return False
    
    # Expandir caminho completo
    opencode_path = os.path.abspath(os.path.expanduser(opencode_path))
    log_success(f"Projeto encontrado: {opencode_path}")
    
    # Validar URL GitHub
    if not github_url.endswith('.git') and not 'github.com' in github_url:
        log_warning("URL do GitHub pode estar inválida")
    
    log_success("Argumentos validados")
    return True, opencode_path

# ============================================================================
# ETAPA 2: Inicializar repositório Git
# ============================================================================
def init_git_repo(project_path):
    """Inicializa o repositório Git se necessário"""
    log_info("Etapa 2: Verificando repositório Git...")
    
    git_dir = os.path.join(project_path, '.git')
    
    if os.path.isdir(git_dir):
        log_warning("Repositório Git já existe")
        return True
    
    log_info("Inicializando repositório Git...")
    success, stdout, stderr = run_command('git init', cwd=project_path)
    
    if not success:
        log_error(f"Erro ao inicializar Git: {stderr}")
        return False
    
    # Configurar usuário Git local
    run_command('git config user.name "OpenCode Sync Bot"', cwd=project_path)
    run_command('git config user.email "sync@opencode-github.local"', cwd=project_path)
    
    log_success("Repositório Git inicializado")
    return True

# ============================================================================
# ETAPA 3: Criar .gitignore
# ============================================================================
def create_gitignore(project_path):
    """Cria um .gitignore padrão se não existir"""
    log_info("Etapa 3: Verificando .gitignore...")
    
    gitignore_path = os.path.join(project_path, '.gitignore')
    
    if os.path.isfile(gitignore_path):
        log_warning(".gitignore já existe")
        return True
    
    gitignore_content = """# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
venv/
env/
.venv/

# Build files
dist/
build/
*.o
*.a
*.so

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store
*.sublime-project
*.sublime-workspace

# Environment
.env
.env.local
.env.*.local
.env.production

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# OS
Thumbs.db
.DS_Store
.AppleDouble
.LSOverride

# Testing
.coverage
htmlcov/
.pytest_cache/

# IDE Generated files
*.iml
.classpath
.project
.settings/

# Temporary files
*.tmp
*.bak
*~
.#*
"""
    
    try:
        with open(gitignore_path, 'w') as f:
            f.write(gitignore_content)
        log_success(".gitignore criado")
        return True
    except Exception as e:
        log_error(f"Erro ao criar .gitignore: {str(e)}")
        return False

# ============================================================================
# ETAPA 4: Adicionar arquivos
# ============================================================================
def add_files(project_path):
    """Adiciona todos os arquivos ao Git"""
    log_info("Etapa 4: Adicionando arquivos ao Git...")
    
    success, stdout, stderr = run_command('git add .', cwd=project_path)
    
    if not success:
        log_error(f"Erro ao adicionar arquivos: {stderr}")
        return False
    
    log_success("Arquivos adicionados")
    return True

# ============================================================================
# ETAPA 5: Fazer commit
# ============================================================================
def commit_changes(project_path):
    """Faz commit das mudanças"""
    log_info("Etapa 5: Verificando mudanças...")
    
    # Verificar se há mudanças
    success, stdout, stderr = run_command('git diff --quiet --cached', cwd=project_path)
    
    if success:  # Sem mudanças
        log_warning("Nenhuma mudança para sincronizar")
        return True
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    commit_msg = f"Sync OpenCode → GitHub [{timestamp}]"
    
    log_info("Fazendo commit das mudanças...")
    success, stdout, stderr = run_command(
        f'git commit -m "{commit_msg}"',
        cwd=project_path
    )
    
    if not success and "nothing to commit" not in stderr:
        log_warning(f"Não foi possível fazer commit: {stderr}")
        return True
    
    log_success("Commit realizado")
    return True

# ============================================================================
# ETAPA 6: Configurar remote
# ============================================================================
def configure_remote(project_path, github_url):
    """Configura o remote do GitHub"""
    log_info("Etapa 6: Configurando remote do GitHub...")
    
    # Verificar se remote existe
    success, stdout, stderr = run_command('git remote', cwd=project_path)
    
    if 'origin' in stdout:
        log_info("Atualizando URL do remote 'origin'...")
        run_command(f'git remote set-url origin "{github_url}"', cwd=project_path)
    else:
        log_info("Adicionando remote 'origin'...")
        success, stdout, stderr = run_command(
            f'git remote add origin "{github_url}"',
            cwd=project_path
        )
        if not success:
            log_error(f"Erro ao adicionar remote: {stderr}")
            return False
    
    log_success(f"Remote configurado: {github_url}")
    return True

# ============================================================================
# ETAPA 7: Verificar branch
# ============================================================================
def setup_main_branch(project_path):
    """Garante que o branch é 'main'"""
    log_info("Etapa 7: Verificando branch principal...")
    
    success, stdout, stderr = run_command('git rev-parse --abbrev-ref HEAD', cwd=project_path)
    current_branch = stdout.strip()
    
    if current_branch != 'main':
        log_info(f"Renomeando branch '{current_branch}' para 'main'...")
        success, stdout, stderr = run_command('git branch -M main', cwd=project_path)
        if not success:
            log_error(f"Erro ao renomear branch: {stderr}")
            return False
    
    log_success("Branch principal: main")
    return True

# ============================================================================
# ETAPA 8: Push para GitHub
# ============================================================================
def push_to_github(project_path):
    """Faz push para o GitHub"""
    log_info("Etapa 8: Fazendo push para GitHub...")
    
    success, stdout, stderr = run_command('git push -u origin main', cwd=project_path)
    
    if not success:
        if "Permission denied" in stderr or "authentication" in stderr.lower():
            log_error("Erro de autenticação ao fazer push")
            log_info("Dicas de resolução:")
            print("  1. Configure SSH ou HTTPS: git config --global credential.helper store")
            print("  2. Gere um Personal Access Token: https://github.com/settings/tokens")
            print("  3. Use: git push -u origin main --force (cuidado!)")
            return False
        else:
            log_warning(f"Erro ao fazer push: {stderr}")
            return False
    
    log_success("Push realizado com sucesso!")
    return True

# ============================================================================
# ETAPA 9: Criar relatório
# ============================================================================
def create_status_report(project_path, github_url):
    """Cria arquivo de status da sincronização"""
    log_info("Etapa 9: Criando relatório...")
    
    timestamp = datetime.now().isoformat()
    status_file = os.path.join(project_path, '.sync-status.json')
    
    status_data = {
        "last_sync": timestamp,
        "opencode_path": project_path,
        "github_url": github_url,
        "branch": "main",
        "status": "success"
    }
    
    try:
        with open(status_file, 'w') as f:
            json.dump(status_data, f, indent=2)
        log_success("Relatório criado: .sync-status.json")
        return True
    except Exception as e:
        log_error(f"Erro ao criar relatório: {str(e)}")
        return False

# ============================================================================
# MAIN
# ============================================================================
def main():
    """Função principal"""
    print(f"{Colors.BOLD}{Colors.BLUE}")
    print("=" * 70)
    print("OpenCode ↔ GitHub Sync Script (Python)")
    print("=" * 70)
    print(f"{Colors.ENDC}\n")
    
    # Validar argumentos
    if len(sys.argv) < 3:
        log_error("Argumentos insuficientes!")
        print("\nUso: python3 sync-opencode-github.py <caminho-projeto> <url-github>")
        print("Exemplo: python3 sync-opencode-github.py ~/meu-projeto https://github.com/usuario/meu-repo.git\n")
        sys.exit(1)
    
    opencode_path = sys.argv[1]
    github_url = sys.argv[2]
    
    # Validar entrada
    is_valid, opencode_path = validate_inputs(opencode_path, github_url)
    if not is_valid:
        sys.exit(1)
    
    print(f"📁 Projeto: {opencode_path}")
    print(f"🔗 GitHub: {github_url}\n")
    
    # Executar etapas
    steps = [
        ("Inicializar Git", lambda: init_git_repo(opencode_path)),
        ("Criar .gitignore", lambda: create_gitignore(opencode_path)),
        ("Adicionar arquivos", lambda: add_files(opencode_path)),
        ("Fazer commit", lambda: commit_changes(opencode_path)),
        ("Configurar remote", lambda: configure_remote(opencode_path, github_url)),
        ("Setup branch main", lambda: setup_main_branch(opencode_path)),
        ("Push para GitHub", lambda: push_to_github(opencode_path)),
        ("Criar relatório", lambda: create_status_report(opencode_path, github_url)),
    ]
    
    for step_name, step_func in steps:
        try:
            if not step_func():
                log_error(f"Etapa falhou: {step_name}")
                sys.exit(1)
        except Exception as e:
            log_error(f"Erro na etapa '{step_name}': {str(e)}")
            sys.exit(1)
    
    # Resumo final
    print(f"\n{Colors.GREEN}{Colors.BOLD}")
    print("=" * 70)
    print("SINCRONIZAÇÃO CONCLUÍDA COM SUCESSO!")
    print("=" * 70)
    print(f"{Colors.ENDC}\n")
    
    print("Resumo:")
    print(f"  📁 Projeto: {opencode_path}")
    print(f"  🔗 GitHub: {github_url}")
    print(f"  📊 Branch: main")
    print(f"  ⏱️  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nPróximos passos:")
    print(f"  1. Acesse: {github_url}")
    print("  2. Verifique os arquivos no GitHub")
    print("  3. Para sincronizações futuras, execute este script novamente")
    print()

if __name__ == "__main__":
    main()
