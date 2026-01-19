# 🚀 Guia: Subindo o Projeto para o GitHub

## 📋 Passo a Passo Completo

### 1️⃣ Preparar o Repositório Local

Abra o Terminal na pasta do projeto e execute:

```bash
# Inicializar repositório Git
git init

# Adicionar todos os arquivos
git add .

# Fazer o primeiro commit
git commit -m "🎉 Initial commit: CidadeViva - App Premium para Rio de Janeiro"
```

---

### 2️⃣ Conectar com o GitHub

```bash
# Adicionar o repositório remoto
git remote add origin https://github.com/mcoutinho2512/App-CidadeViva.git

# Verificar se foi adicionado corretamente
git remote -v
```

Você deve ver:
```
origin  https://github.com/mcoutinho2512/App-CidadeViva.git (fetch)
origin  https://github.com/mcoutinho2512/App-CidadeViva.git (push)
```

---

### 3️⃣ Subir o Código

```bash
# Renomear branch para main (se necessário)
git branch -M main

# Fazer push para o GitHub
git push -u origin main
```

Se pedir autenticação, use:
- **Username**: seu usuário do GitHub
- **Password**: seu Personal Access Token (não a senha)

---

### 4️⃣ Criar Personal Access Token (se necessário)

Se não tem token, crie um:

1. Vá para: https://github.com/settings/tokens
2. Clique em **"Generate new token"** → **"Classic"**
3. Dê um nome: `CidadeViva Token`
4. Marque a permissão: **`repo`**
5. Clique em **"Generate token"**
6. **COPIE O TOKEN** (só aparece uma vez!)
7. Use como senha no git push

---

### 5️⃣ Estrutura de Commits Recomendada

Para commits futuros, use este padrão:

```bash
# Feature nova
git commit -m "✨ feat: Adiciona nova feature X"

# Correção de bug
git commit -m "🐛 fix: Corrige problema Y"

# Documentação
git commit -m "📝 docs: Atualiza README com informação Z"

# Estilo/Design
git commit -m "💄 style: Ajusta design do componente W"

# Refatoração
git commit -m "♻️ refactor: Melhora estrutura do código"

# Performance
git commit -m "⚡ perf: Otimiza carregamento das câmeras"

# Testes
git commit -m "✅ test: Adiciona testes para AlertsViewModel"
```

---

## 🔄 Workflow Diário

### Começar o dia:
```bash
# Atualizar código
git pull origin main
```

### Durante o desenvolvimento:
```bash
# Ver status
git status

# Adicionar arquivos específicos
git add arquivo.swift

# Ou adicionar tudo
git add .

# Commit
git commit -m "✨ feat: Descrição da mudança"

# Push
git push origin main
```

### Criar branch para feature:
```bash
# Criar e mudar para nova branch
git checkout -b feature/nova-funcionalidade

# Trabalhar na branch...
git add .
git commit -m "✨ feat: Nova funcionalidade"

# Push da branch
git push origin feature/nova-funcionalidade

# Depois criar Pull Request no GitHub
```

---

## 🌿 Branches Recomendadas

```
main          → Produção (sempre estável)
develop       → Desenvolvimento ativo
feature/*     → Novas features
bugfix/*      → Correções de bugs
hotfix/*      → Correções urgentes
```

### Criar estrutura:
```bash
# Criar branch develop
git checkout -b develop
git push origin develop

# Voltar para main
git checkout main
```

---

## 🔍 Comandos Úteis

```bash
# Ver histórico
git log --oneline --graph --all

# Ver mudanças
git diff

# Ver branches
git branch -a

# Desfazer último commit (mantém mudanças)
git reset --soft HEAD~1

# Limpar arquivos não rastreados
git clean -fd

# Ver arquivos ignorados
git status --ignored
```

---

## 📦 Arquivos Importantes Criados

✅ `.gitignore` - Ignora arquivos desnecessários  
✅ `README.md` - Documentação do projeto  
✅ `LICENSE` - Licença MIT  
✅ `GUIA_GIT.md` - Este guia  

---

## ⚠️ Importante

### Nunca commitar:
- ❌ `xcuserdata/`
- ❌ `DerivedData/`
- ❌ `.DS_Store`
- ❌ Senhas ou tokens
- ❌ Arquivos de configuração locais

### Sempre commitar:
- ✅ Código fonte (`.swift`)
- ✅ Assets (`.xcassets`)
- ✅ Storyboards/XIBs
- ✅ Documentação
- ✅ Arquivos de configuração do projeto

---

## 🎯 Checklist Antes do Push

- [ ] Código compila sem erros
- [ ] Testes passam (se houver)
- [ ] Sem warnings importantes
- [ ] Código comentado
- [ ] README atualizado (se necessário)
- [ ] `.gitignore` configurado
- [ ] Mensagem de commit descritiva

---

## 🆘 Problemas Comuns

### Erro: "Updates were rejected"
```bash
# Solução: Pull antes de push
git pull origin main --rebase
git push origin main
```

### Erro: "Permission denied"
```bash
# Solução: Verificar token ou SSH
git remote set-url origin https://[TOKEN]@github.com/mcoutinho2512/App-CidadeViva.git
```

### Erro: "Large files"
```bash
# Solução: Git LFS para arquivos grandes
git lfs install
git lfs track "*.mp4"
git add .gitattributes
```

---

## 🔐 Configurar SSH (Opcional)

Para não precisar de senha toda vez:

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu-email@example.com"

# Copiar chave pública
cat ~/.ssh/id_ed25519.pub

# Adicionar no GitHub:
# Settings → SSH and GPG keys → New SSH key

# Mudar URL para SSH
git remote set-url origin git@github.com:mcoutinho2512/App-CidadeViva.git
```

---

## 📊 Estatísticas do Projeto

Depois de subir, veja estatísticas:

```bash
# Linhas de código
git ls-files | grep ".swift$" | xargs wc -l

# Número de commits
git rev-list --count main

# Contribuidores
git shortlog -sn
```

---

## 🎉 Pronto!

Seu projeto agora está no GitHub! 

### Próximos passos:
1. ⭐ Pedir para amigos darem estrela
2. 📝 Manter README atualizado
3. 🐛 Usar Issues para bugs
4. 🔄 Usar Pull Requests para features
5. 📦 Criar Releases para versões

### Links úteis:
- Seu repositório: https://github.com/mcoutinho2512/App-CidadeViva
- Issues: https://github.com/mcoutinho2512/App-CidadeViva/issues
- Pull Requests: https://github.com/mcoutinho2512/App-CidadeViva/pulls

---

*Bom trabalho! 🚀*
