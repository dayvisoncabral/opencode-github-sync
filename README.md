# 🔄 OpenCode ↔ GitHub Sync Script

Um conjunto de scripts para sincronizar automaticamente seus projetos do OpenCode com o GitHub.

## 📋 Características

✅ Sincronização automática de projetos OpenCode com GitHub  
✅ Disponível em Bash e Python (multiplataforma)  
✅ Inicialização automática de repositório Git  
✅ Criação de `.gitignore` inteligente  
✅ Tratamento de erros e logging colorido  
✅ Suporte a sincronização contínua via cron  
✅ Relatório de status em JSON  

## 🚀 Início Rápido

### Pré-requisitos

- Git instalado e configurado
- Terminal/Console (Bash, PowerShell, cmd)
- Python 3.6+ (apenas para versão Python)

### Instalação

1. Clone este repositório:
```bash
git clone https://github.com/dayvisoncabral/opencode-github-sync.git
cd opencode-github-sync
```

2. Dê permissão de execução (Linux/macOS):
```bash
chmod +x sync-opencode-github.sh
chmod +x sync-opencode-github.py
```

## 📖 Como Usar

### Opção 1: Usando Bash (Linux/macOS)

```bash
./sync-opencode-github.sh /caminho/para/projeto-opencode https://github.com/usuario/repo.git
```

**Exemplo:**
```bash
./sync-opencode-github.sh ~/meu-projeto https://github.com/dayvisoncabral/meu-projeto.git
```

### Opção 2: Usando Python (Windows/macOS/Linux)

```bash
python3 sync-opencode-github.py /caminho/para/projeto-opencode https://github.com/usuario/repo.git
```

**Exemplo:**
```bash
python3 sync-opencode-github.py ~/meu-projeto https://github.com/dayvisoncabral/meu-projeto.git
```

## 🔧 Configuração Passo a Passo

### 1. Preparar o Repositório GitHub

Se você ainda não tem um repositório no GitHub:

1. Acesse [github.com/new](https://github.com/new)
2. Crie um novo repositório com o nome desejado
3. **Não inicialize** com README, .gitignore ou license
4. Copie a URL HTTPS ou SSH do repositório

### 2. Executar o Script

```bash
# Com Bash
./sync-opencode-github.sh ~/meu-projeto https://github.com/seu-usuario/seu-repo.git

# Com Python
python3 sync-opencode-github.py ~/meu-projeto https://github.com/seu-usuario/seu-repo.git
```

### 3. Autenticar no GitHub

Quando o script pedir autenticação, você tem duas opções:

#### Opção A: HTTPS com Personal Access Token
```bash
# Gere um token em: https://github.com/settings/tokens
git config --global credential.helper store
# Na primeira vez, use seu token como senha
```

#### Opção B: SSH (Recomendado)
```bash
# Gere uma chave SSH
ssh-keygen -t ed25519 -C "seu-email@example.com"

# Adicione ao GitHub: https://github.com/settings/ssh/new

# Use a URL SSH no script
python3 sync-opencode-github.py ~/meu-projeto git@github.com:seu-usuario/seu-repo.git
```

## 📊 Fluxo de Execução

```
┌─────────────────────────────────────────────────────────┐
│  Etapa 1: Validar argumentos                            │
├─────────────────────────────────────────────────────────┤
│  Etapa 2: Inicializar repositório Git                   │
├─────────────────────────────────────────────────────────┤
│  Etapa 3: Criar .gitignore                              │
├─────────────────────────────────────────────────────────┤
│  Etapa 4: Adicionar arquivos (git add .)                │
├─────────────────────────────────────────────────────────┤
│  Etapa 5: Fazer commit                                  │
├─────────────────────────────────────────────────────────┤
│  Etapa 6: Configurar remote do GitHub                   │
├─────────────────────────────────────────────────────────┤
│  Etapa 7: Definir branch como 'main'                    │
├─────────────────────────────────────────────────────────┤
│  Etapa 8: Fazer push para GitHub                        │
├─────────────────────────────────────────────────────────┤
│  Etapa 9: Criar relatório de status                     │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Sincronização Automática

### Linux/macOS: Cron Job

Edite o crontab:
```bash
crontab -e
```

Adicione uma linha para sincronizar a cada 30 minutos:
```cron
*/30 * * * * /caminho/completo/sync-opencode-github.sh ~/meu-projeto https://github.com/usuario/repo.git >> /tmp/opencode-sync.log 2>&1
```

Para sincronizar diariamente às 2h da manhã:
```cron
0 2 * * * python3 /caminho/completo/sync-opencode-github.py ~/meu-projeto https://github.com/usuario/repo.git >> /tmp/opencode-sync.log 2>&1
```

### Windows: Task Scheduler

1. Abra "Agendador de Tarefas"
2. Clique em "Criar Tarefa Básica"
3. Configure o gatilho (frequência desejada)
4. Defina a ação como:
   ```
   Programa: python.exe
   Argumentos: C:\caminho\sync-opencode-github.py C:\projeto https://github.com/usuario/repo.git
   ```

## 📋 Arquivos Gerados

Após a execução bem-sucedida, estes arquivos serão criados/modificados:

- `.git/` - Diretório do repositório Git
- `.gitignore` - Arquivo de exclusão padrão
- `.sync-status.json` - Relatório de sincronização

**Exemplo de `.sync-status.json`:**
```json
{
  "last_sync": "2024-01-15T14:30:45.123456",
  "opencode_path": "/home/usuario/meu-projeto",
  "github_url": "https://github.com/usuario/repo.git",
  "branch": "main",
  "status": "success"
}
```

## 🐛 Resolução de Problemas

### ❌ "Erro de autenticação ao fazer push"

**Solução:**
```bash
# 1. Gere um Personal Access Token
# https://github.com/settings/tokens

# 2. Configure o armazenamento de credenciais
git config --global credential.helper store

# 3. Tente novamente
python3 sync-opencode-github.py ~/meu-projeto https://github.com/usuario/repo.git
```

### ❌ "Repositório não encontrado"

**Solução:**
- Verifique se a URL do GitHub está correta
- Certifique-se de ter acesso ao repositório
- Use `git remote -v` para verificar a URL configurada

### ❌ "Diretório do OpenCode não encontrado"

**Solução:**
- Use o caminho absoluto: `/home/usuario/meu-projeto`
- Ou caminho relativo: `~/meu-projeto`
- Verifique se o diretório existe: `ls -la ~/meu-projeto`

### ❌ Script não tem permissão de execução

**Solução (Linux/macOS):**
```bash
chmod +x sync-opencode-github.sh
chmod +x sync-opencode-github.py
```

## 📝 Exemplos de Uso

### Sincronizar um projeto Node.js
```bash
python3 sync-opencode-github.py ~/my-node-app https://github.com/myusername/my-node-app.git
```

### Sincronizar um projeto Python
```bash
./sync-opencode-github.sh ~/my-python-project https://github.com/myusername/my-python-project.git
```

### Sincronizar e verificar o resultado
```bash
python3 sync-opencode-github.py ~/meu-projeto https://github.com/usuario/repo.git
cd ~/meu-projeto
git log --oneline
git remote -v
```

## 🔧 Guia de Setup - SisEstat 11 BPM

Para sincronizar o projeto **SisEstat 11 BPM** do OpenCode com o GitHub:

### Passo 1: Preparar o Projeto Local

```bash
cd "G:\Meu Drive\projeto estatistica"
```

### Passo 2: Inicializar Git

```bash
git init
git add .
git status  # Verifique se .env, *.db, backups/ e *.xlsx NÃO aparecem
```

### Passo 3: Verificar .gitignore

Antes de fazer commit, certifique-se de que o `.gitignore` contém:

```
# Environment files
.env
.env.local
.env.*.local

# Database files
*.db
*.sqlite
*.sqlite3

# Excel files
*.xlsx
*.xls

# Backup files
backups/
backup/
*.bak
```

### Passo 4: Fazer Commit Inicial

```bash
git commit -m "Importação inicial do SisEstat 11 BPM"
```

### Passo 5: Autenticar no GitHub

```bash
gh auth login
```

Siga as instruções na tela para autenticar.

### Passo 6: Criar Repositório Privado e Fazer Push

```bash
gh repo create sisestat-11bpm --private --source=. --push
```

✅ **Pronto!** Seu repositório está criado e sincronizado!

### Verificar o Resultado

```bash
git log --oneline
git remote -v
```

## 📚 Referências

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [SSH Keys GitHub](https://github.com/settings/ssh)
- [GitHub CLI](https://cli.github.com/)

## ⚖️ Licença

MIT License - veja o arquivo LICENSE para detalhes.

## 🤝 Contribuindo

Contribuições são bem-vindas! Para sugestões de melhoria:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 💬 Suporte

Se encontrar problemas ou tiver dúvidas:

1. Verifique a seção "Resolução de Problemas"
2. Abra uma [issue](https://github.com/dayvisoncabral/opencode-github-sync/issues)
3. Consulte a [documentação do Git](https://git-scm.com/doc)

## 🔮 Roadmap

- [ ] Interface gráfica (GUI)
- [ ] Suporte para múltiplos remotes
- [ ] Webhook automático do OpenCode
- [ ] Sincronização bidirecional
- [ ] GitHub CLI integration
- [ ] Painel de controle web

---

**Desenvolvido com ❤️ para facilitar sua vida!**

Acesse nosso repositório: [https://github.com/dayvisoncabral/opencode-github-sync](https://github.com/dayvisoncabral/opencode-github-sync)
