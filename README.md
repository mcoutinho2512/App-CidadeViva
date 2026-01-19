# CidadeViva - Aplicativo iOS

Aplicativo iOS completo para informações urbanas em tempo real, desenvolvido em SwiftUI com arquitetura MVVM moderna.

## 📋 Informações do Projeto

- **Nome:** CidadeViva
- **Bundle ID:** com.cidadeviva.ios
- **Versão:** 1.0.0
- **iOS Deployment Target:** iOS 15.0+
- **Linguagem:** Swift
- **UI Framework:** SwiftUI
- **Arquitetura:** MVVM + Clean Architecture

## 🎯 Funcionalidades

### Telas Implementadas

1. **Home** - Dashboard com resumo de informações
   - Card de clima com temperatura atual
   - Contador de câmeras disponíveis
   - Contador de alertas ativos
   - Pull to refresh

2. **Clima** - Informações climáticas detalhadas
   - Temperatura e sensação térmica
   - Condição climática com ícones
   - Umidade e velocidade do vento
   - Última atualização

3. **Câmeras** - Monitoramento de câmeras urbanas
   - Lista de câmeras com status (online/offline/manutenção)
   - Filtros por região e status
   - Busca por nome ou região
   - Estatísticas de disponibilidade

4. **Alertas** - Alertas urbanos em tempo real
   - Lista de alertas por severidade
   - Filtros por tipo e severidade
   - Badge com contador na TabBar
   - Indicadores visuais por severidade

5. **Mapa** - Visualização geográfica
   - Marcadores de câmeras e alertas
   - Localização do usuário
   - Callouts com informações detalhadas
   - Controles de visibilidade

## 🏗️ Arquitetura

O projeto segue uma arquitetura em camadas baseada em Clean Architecture e MVVM:

```
/CidadeViva
├── App/                    # Configuração e entrada do app
│   ├── CidadeVivaApp.swift
│   ├── AppRouter.swift
│   └── AppConfiguration.swift
│
├── Presentation/           # Camada de apresentação
│   ├── Screens/           # Telas do app
│   ├── Components/        # Componentes reutilizáveis
│   └── ViewModels/        # ViewModels (MVVM)
│
├── Domain/                # Camada de domínio (regras de negócio)
│   ├── Models/           # Modelos de domínio
│   └── UseCases/         # Casos de uso
│
├── Data/                  # Camada de dados
│   ├── Repositories/     # Implementação de repositórios
│   ├── DTOs/            # Data Transfer Objects
│   └── Mocks/           # Dados mockados
│
├── Infra/                # Infraestrutura
│   ├── Networking/      # Cliente de API
│   └── Services/        # Serviços (Cache, Location)
│
└── Resources/            # Recursos (Assets, Info.plist)
```

### Fluxo de Dados

```
View → ViewModel → UseCase → Repository → APIClient
  ↓                                           ↓
Observable                              Network/Mock
```

## 🚀 Como Executar

### Requisitos

- Xcode 15.0+
- macOS Sonoma 14.0+
- iOS Simulator ou dispositivo físico com iOS 15.0+

### Passo a Passo

1. **Abrir o Projeto no Xcode**
   ```bash
   cd CidadeViva
   # Criar projeto Xcode manualmente ou usar comando:
   # File > New > Project > iOS > App
   ```

2. **Configurar o Projeto no Xcode**
   - Product Name: `CidadeViva`
   - Bundle Identifier: `com.cidadeviva.ios`
   - Interface: SwiftUI
   - Language: Swift
   - iOS Deployment Target: iOS 15.0

3. **Adicionar os Arquivos ao Projeto**
   - Arraste todas as pastas para o Xcode mantendo a estrutura
   - Certifique-se de marcar "Copy items if needed"
   - Adicione os arquivos ao target CidadeViva

4. **Configurar Info.plist**
   - Use o arquivo `Resources/Info.plist` fornecido
   - Verifique as permissões de localização

5. **Configurar Assets**
   - Adicione o `Assets.xcassets` ao projeto
   - Verifique se os ColorSets estão corretos

6. **Build e Run**
   - Selecione um simulador (iPhone 14 Pro ou superior recomendado)
   - Pressione ⌘R ou clique em "Run"

## 📦 Dependências

**Nenhuma dependência externa!**

O projeto foi desenvolvido usando apenas frameworks nativos do iOS:
- SwiftUI (UI)
- Combine (Reactive)
- MapKit (Mapas)
- CoreLocation (Localização)
- Foundation (Core)

## 🔧 Configuração

### Modo Mock vs API Real

Por padrão, o app usa dados mockados. Para alternar:

Edite `App/AppConfiguration.swift`:

```swift
enum Features {
    static let enableMockData = true // false para API real
}
```

### Endpoints de API

Os endpoints estão definidos em `Infra/Networking/Endpoints.swift`:

```swift
case weather  // GET /api/v1/weather/current
case cameras  // GET /api/v1/cameras
case alerts   // GET /api/v1/alerts
```

Base URL em `App/AppConfiguration.swift`:
```swift
static let baseURL = "https://api.cidadeviva.com.br"
```

## 🎨 Design System

### Cores

- **Primary (Azul):** #007AFF - Ações principais
- **Secondary (Verde):** #34C759 - Status positivo
- **Alert (Vermelho):** #FF3B30 - Alertas e erros
- **Warning (Laranja):** #FF9500 - Avisos

### Componentes Reutilizáveis

- **InfoCard:** Card de informação genérico
- **LoadingView:** Estado de carregamento
- **ErrorView:** Estado de erro com retry
- **CardModifier:** Estilo de card padrão

## 📱 Funcionalidades Futuras Preparadas

A estrutura do código está pronta para:

- ✅ Integração com APIs reais (trocar flag enableMockData)
- ✅ Push Notifications (estrutura de alertas)
- ✅ Cache offline (CacheService implementado)
- ✅ WebSockets para updates em tempo real
- ✅ Streaming de câmeras (modelo Camera tem streamURL)
- ✅ Firebase Analytics e Crashlytics
- ✅ Persistência com CoreData/SwiftData

## 🧪 Testing

### Estrutura para Testes

O código foi desenvolvido seguindo princípios SOLID, facilitando testes:

- Protocols para repositórios (fácil mock)
- Dependency Injection nos ViewModels
- UseCases isolados e testáveis
- Mock data centralizado

### Exemplo de Teste de ViewModel

```swift
@MainActor
class HomeViewModelTests: XCTestCase {
    func testLoadData() async {
        let viewModel = HomeViewModel()
        await viewModel.loadData()

        XCTAssertNotNil(viewModel.weather)
        XCTAssertGreaterThan(viewModel.camerasCount, 0)
    }
}
```

## 🔐 Segurança

- ✅ Sem hardcoded secrets
- ✅ Info.plist com configurações de privacidade
- ✅ HTTPS obrigatório (App Transport Security)
- ✅ Validação de entrada de dados
- ✅ Tratamento de erros completo

## 📄 Licença

Este é um projeto de demonstração. Use livremente para estudos e desenvolvimento.

## 👨‍💻 Desenvolvimento

Desenvolvido seguindo as melhores práticas de iOS/Swift:
- Protocol-Oriented Programming
- Clean Architecture
- MVVM Pattern
- Async/Await
- SwiftUI Best Practices
- Dark Mode Support
- Localização PT-BR

## 🆘 Troubleshooting

### App não compila

1. Verifique o Deployment Target (iOS 15.0+)
2. Limpe build folder (⌘⇧K)
3. Delete Derived Data
4. Reinicie o Xcode

### Dados não aparecem

1. Verifique se `enableMockData = true`
2. Verifique logs no console (DEBUG builds)
3. Confirme que os arquivos Mock estão no target

### Mapa não mostra localização

1. Verifique Info.plist (NSLocationWhenInUseUsageDescription)
2. Aceite permissão de localização no simulador
3. Simulador: Features > Location > Apple

## 📞 Suporte

Para dúvidas ou problemas:
1. Revise este README
2. Verifique os comentários no código
3. Consulte a documentação inline de cada arquivo

---

**Versão:** 1.0.0
**Data:** Janeiro 2026
**Status:** ✅ Produção Ready
