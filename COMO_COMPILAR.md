# 🚀 Como Compilar o Projeto CidadeViva

## ✅ Projeto Xcode Criado!

O arquivo `CidadeViva.xcodeproj` foi criado com sucesso e está pronto para uso!

---

## 📱 Como Abrir e Compilar

### Passo 1: Abrir o Projeto
1. Navegue até a pasta do projeto:
   ```
   /Users/magnuncoutinho/Desenvolvimento/Aplicativo/CidadeViva
   ```

2. Dê um duplo-clique no arquivo:
   ```
   CidadeViva.xcodeproj
   ```

   Ou abra via terminal:
   ```bash
   open CidadeViva.xcodeproj
   ```

### Passo 2: Aguardar Indexação
- O Xcode irá abrir e começar a indexar todos os 61 arquivos Swift
- Aguarde a barra de progresso no topo terminar (pode levar 1-2 minutos)

### Passo 3: Selecionar Simulador
- No topo da janela do Xcode, ao lado do botão ▶️ Run
- Clique no menu de dispositivos
- Escolha um simulador (ex: iPhone 15 Pro)

### Passo 4: Compilar e Executar
- Clique no botão ▶️ **Run** (ou pressione `Cmd + R`)
- O Xcode irá compilar o projeto
- O simulador será aberto automaticamente
- O app será instalado e executado!

---

## 🛠️ Configurações do Projeto

O projeto foi configurado com:

✅ **Target iOS**: 16.0+
✅ **SwiftUI**: Interface moderna
✅ **Bundle ID**: com.prefeitura.CidadeViva
✅ **Display Name**: Cidade Viva
✅ **Permissões**:
- Localização (NSLocationWhenInUseUsageDescription)

✅ **Frameworks Incluídos**:
- SwiftUI
- MapKit (para mapas)
- CoreLocation (para localização)

✅ **61 Arquivos Swift** organizados em:
- App (3 arquivos)
- Presentation (18 arquivos)
- Domain (15 arquivos)
- Data (18 arquivos)
- Infra (5 arquivos)
- Resources (Assets)

---

## 🎨 Funcionalidades Disponíveis

Ao executar, você terá acesso a **9 abas**:

1. 🏠 **Início** - Dashboard principal
2. 📅 **Eventos** - Programação de eventos da cidade
3. 📰 **Notícias** - Notícias e comunicados
4. 📍 **Pontos** - Pontos de interesse (POIs)
5. 🗺️ **Rotas** - Navegação e rotas
6. ☁️ **Clima** - Previsão do tempo
7. 📹 **Câmeras** - Câmeras de trânsito
8. ⚠️ **Alertas** - Alertas da cidade
9. 🗺️ **Mapa** - Visualização geral no mapa

---

## 🧪 Testando com Dados Mock

O app está configurado para usar **dados mock** (simulados) por padrão:
- 4 eventos de exemplo
- 3 notícias de exemplo
- 5 POIs de exemplo
- Cálculo de rotas automático

Para testar **sem backend**, apenas compile e execute!

---

## 🔧 Possíveis Problemas

### Erro: "Signing for CidadeViva requires a development team"

**Solução**:
1. Clique no projeto (ícone azul) na navegação lateral esquerda
2. Selecione o target "CidadeViva"
3. Vá para a aba "Signing & Capabilities"
4. Marque "Automatically manage signing"
5. Selecione sua Apple ID em "Team"

### Erro: "Developer cannot be verified"

**Solução**:
1. Vá em System Settings → Privacy & Security
2. Role até embaixo e clique em "Allow Anyway" ao lado do desenvolvedor

### Simulador não abre

**Solução**:
```bash
# Reiniciar simuladores
killall Simulator
```

---

## 📊 Estrutura do Projeto no Xcode

Quando abrir, você verá esta estrutura:

```
CidadeViva
├── App
│   ├── CidadeVivaApp.swift (Entry point)
│   ├── AppRouter.swift
│   └── AppConfiguration.swift
├── Presentation
│   ├── Screens (HomeView, WeatherView, etc.)
│   ├── Views (EventsView, NewsView, POIsView, NavigationView)
│   ├── ViewModels
│   └── Components
├── Domain
│   ├── Models
│   └── UseCases
├── Data
│   ├── Repositories
│   ├── DTOs
│   └── Mocks
├── Infra
│   ├── Networking
│   └── Services
└── Resources
    └── Assets.xcassets
```

---

## ✨ Dicas

1. **Primeira compilação** pode demorar mais (2-3 minutos)
2. **Use Cmd + B** para compilar sem executar
3. **Use Cmd + Shift + K** para limpar build (se algo der errado)
4. **Console do Xcode** (parte inferior) mostra logs úteis
5. **Breakpoints** podem ser adicionados clicando na margem esquerda do código

---

## 🎯 Próximos Passos

Após testar o app funcionando:

### Opção B - Conectar ao Backend Django
- Configurar URL do backend em `AppConfiguration.swift`
- Implementar autenticação JWT
- Substituir mock data por chamadas API reais

### Opção C - Customização Visual
- Adaptar cores para match com totem
- Adicionar animações
- Polish UI/UX

---

## 📞 Suporte

Se encontrar algum problema:
1. Verifique os logs no Console do Xcode
2. Revise as configurações de assinatura
3. Tente limpar o build (`Cmd + Shift + K`)
4. Feche e reabra o Xcode

---

**Status**: ✅ Projeto pronto para compilar!
**Data**: 2026-01-18
**Versão**: 1.0
