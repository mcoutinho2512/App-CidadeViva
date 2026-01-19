# Instruções de Build - CidadeViva

## 🎯 Guia Rápido de Configuração no Xcode

### Passo 1: Criar Novo Projeto

1. Abra o Xcode
2. File > New > Project
3. Selecione "iOS" > "App"
4. Clique em "Next"

### Passo 2: Configurar Projeto

Preencha os campos:
- **Product Name:** `CidadeViva`
- **Team:** Selecione seu time (ou deixe em None para desenvolvimento)
- **Organization Identifier:** `com.cidadeviva`
- **Bundle Identifier:** `com.cidadeviva.ios` (será gerado automaticamente)
- **Interface:** SwiftUI
- **Language:** Swift
- **Storage:** None (não marcar Core Data)

Clique em "Next" e escolha onde salvar o projeto.

### Passo 3: Configurar Deployment Target

1. Selecione o projeto no navegador (ícone azul)
2. Em "TARGETS" > CidadeViva
3. Aba "General"
4. Em "Deployment Info":
   - **Minimum Deployments:** iOS 15.0
   - **iPhone Orientation:** Portrait, Landscape Left, Landscape Right
   - **iPad Orientation:** Todas marcadas
   - **Supports multiple windows:** Desmarcado

### Passo 4: Remover Arquivos Gerados Automaticamente

O Xcode criará alguns arquivos que não usaremos. Delete:
- `ContentView.swift` (já temos nossa própria estrutura)
- Qualquer arquivo `Assets.xcassets` vazio

### Passo 5: Adicionar Arquivos do Projeto

**IMPORTANTE:** Adicione os arquivos mantendo a estrutura de pastas.

1. Arraste a pasta `App` para o projeto no Xcode
2. Na janela que aparecer:
   - ✅ Marque "Copy items if needed"
   - ✅ Marque "Create groups"
   - ✅ Certifique-se que o target CidadeViva está selecionado
3. Repita para as pastas:
   - `Presentation`
   - `Domain`
   - `Data`
   - `Infra`
   - `Resources`

**Resultado esperado:**
```
CidadeViva/
├── CidadeViva/
│   ├── App/
│   ├── Presentation/
│   ├── Domain/
│   ├── Data/
│   ├── Infra/
│   └── Resources/
└── CidadeViva.xcodeproj
```

### Passo 6: Configurar Info.plist

1. Selecione o projeto > Target CidadeViva > Info
2. Ou use o arquivo `Resources/Info.plist` fornecido

**Chaves importantes a adicionar:**

```xml
NSLocationWhenInUseUsageDescription: "Precisamos da sua localização para mostrar informações da sua região e centralizar o mapa na sua posição atual."
```

**No Xcode:**
1. Botão direito em Info.plist > Open As > Source Code
2. Cole o conteúdo do arquivo `Resources/Info.plist`

### Passo 7: Configurar Assets

1. Delete o `Assets.xcassets` criado automaticamente pelo Xcode (se existir)
2. Arraste a pasta `Resources/Assets.xcassets` para o projeto
3. Marque "Copy items if needed"
4. Verifique se os ColorSets aparecem:
   - PrimaryColor (Azul #007AFF)
   - SecondaryColor (Verde #34C759)
   - AlertColor (Vermelho #FF3B30)
   - WarningColor (Laranja #FF9500)

### Passo 8: Build Settings

1. Selecione o projeto > Target CidadeViva > Build Settings
2. Procure por "Swift Language Version"
3. Certifique-se que está em "Swift 5"

### Passo 9: Primeira Build

1. Selecione um simulador (iPhone 14 Pro recomendado)
2. Pressione ⌘B para build
3. Aguarde a compilação

**Se houver erros:**
- Clean Build Folder: ⌘⇧K
- Restart Xcode
- Verifique se todos os arquivos estão no target

### Passo 10: Executar

1. Pressione ⌘R ou clique no botão Play
2. O simulador abrirá
3. Aceite permissão de localização quando solicitado
4. O app deve aparecer com a TabBar e 5 abas

## ✅ Checklist de Verificação

Antes de executar, verifique:

- [ ] Deployment Target = iOS 15.0
- [ ] Bundle Identifier = com.cidadeviva.ios
- [ ] Todos os arquivos Swift adicionados ao target
- [ ] Assets.xcassets com ColorSets configurados
- [ ] Info.plist com permissão de localização
- [ ] Nenhum erro de compilação

## 🔧 Configurações Adicionais (Opcional)

### Signing & Capabilities

1. Selecione o projeto > Target > Signing & Capabilities
2. Se for testar em dispositivo real:
   - Selecione seu Team
   - Xcode gerará provisioning automaticamente

### Simulador Recomendado

Para melhor experiência:
- iPhone 14 Pro (iOS 17.0+)
- iPhone 15 Pro (iOS 17.0+)
- iPad Pro 12.9" (para testar layout em tablet)

### Localização no Simulador

Para testar funcionalidades de mapa:
1. No simulador: Features > Location
2. Escolha uma localização:
   - Custom Location (São Paulo: -23.5505, -46.6333)
   - Apple (Cupertino)
   - City Run

## 📱 Testando as Funcionalidades

### Home
- Deve mostrar cards de clima, câmeras e alertas
- Pull down para refresh

### Clima
- Temperatura em grande destaque
- Ícone do clima
- Detalhes de umidade e vento

### Câmeras
- Lista de 6 câmeras mockadas
- Filtros funcionais
- Busca por nome

### Alertas
- 5 alertas mockados
- Filtros por tipo/severidade
- Badge na TabBar com contador

### Mapa
- Marcadores de câmeras (azul/verde/vermelho)
- Marcadores de alertas (laranja/vermelho)
- Botão de centralizar na localização do usuário
- Tap nos marcadores mostra detalhes

## 🐛 Troubleshooting

### Erro: "Module not found"
```
Clean Build Folder (⌘⇧K)
Delete Derived Data
Restart Xcode
```

### Erro: "No such module 'SwiftUI'"
```
Verifique Deployment Target >= iOS 15.0
```

### Assets/Cores não aparecem
```
Verifique se Assets.xcassets está no target
Build Settings > Asset Catalog Compiler
```

### App crasha ao abrir
```
Verifique console para erros
Certifique-se que Info.plist tem todas as keys
```

### Dados mockados não aparecem
```
Verifique AppConfiguration.swift:
enableMockData = true
```

## 🎨 Personalizações

### Mudar Cores do Tema

Edite os ColorSets em `Resources/Assets.xcassets`:
- PrimaryColor.colorset/Contents.json
- SecondaryColor.colorset/Contents.json
- AlertColor.colorset/Contents.json
- WarningColor.colorset/Contents.json

### Mudar Nome do App

1. Info.plist > CFBundleDisplayName
2. Ou: Target > General > Display Name

### Adicionar App Icon

1. Gere ícones em todos os tamanhos (use https://appicon.co)
2. Arraste para AppIcon.appiconset
3. Renomeie de acordo com Contents.json

## 📊 Verificando Logs

Para debug, verifique o console do Xcode:
- 🌐 Logs de rede (quando enableNetworkLogging = true)
- ☁️ Cache hits
- 📹 Carregamento de dados

## 🚀 Deploy para TestFlight (Futuro)

Quando estiver pronto para distribuir:

1. Archive: Product > Archive
2. Distribute App > App Store Connect
3. Upload para TestFlight
4. Configurar App Store Connect

## 📞 Próximos Passos

Após o build bem-sucedido:

1. ✅ Testar todas as telas
2. ✅ Testar rotação de tela
3. ✅ Testar dark mode (⌘⇧A no simulador)
4. ✅ Testar em diferentes tamanhos de iPhone
5. ✅ Integrar APIs reais (trocar enableMockData)
6. ✅ Adicionar testes unitários
7. ✅ Configurar CI/CD

---

**Tempo estimado de setup:** 15-20 minutos

**Status após setup:** App 100% funcional com dados mockados
