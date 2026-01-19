# Arquitetura do CidadeViva

## 📐 Visão Geral

O CidadeViva segue uma arquitetura em camadas baseada em **Clean Architecture** combinada com **MVVM** para a camada de apresentação.

## 🏗️ Diagrama de Camadas

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  ┌─────────┐  ┌──────────────────────┐ │
│  │  Views  │──│    ViewModels        │ │
│  │(SwiftUI)│  │ (@ObservableObject)  │ │
│  └─────────┘  └──────────────────────┘ │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│          DOMAIN LAYER                   │
│  ┌──────────────┐  ┌────────────────┐  │
│  │   Models     │  │   UseCases     │  │
│  │  (Entities)  │  │ (Business Logic)│ │
│  └──────────────┘  └────────────────┘  │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│           DATA LAYER                    │
│  ┌──────────────┐  ┌────────────────┐  │
│  │Repositories  │  │      DTOs      │  │
│  │              │  │  (Data Models) │  │
│  └──────────────┘  └────────────────┘  │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│      INFRASTRUCTURE LAYER               │
│  ┌──────────────┐  ┌────────────────┐  │
│  │  APIClient   │  │   Services     │  │
│  │ (Networking) │  │ (Cache, Location)│ │
│  └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────┘
```

## 📦 Responsabilidades das Camadas

### 1. Presentation Layer

**Responsabilidade:** Interface do usuário e lógica de apresentação

**Componentes:**
- **Views (SwiftUI):** Interface visual
- **ViewModels:** Estado e lógica de apresentação
- **Components:** Componentes reutilizáveis de UI

**Regras:**
- Views nunca acessam dados diretamente
- ViewModels expõem apenas o necessário para a View
- Uso de @Published para reactive updates
- Tratamento de estados (loading, success, error)

**Exemplo:**
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var loadingState: LoadingState = .idle

    private let fetchWeatherUseCase: FetchWeatherUseCase

    func loadData() async {
        loadingState = .loading
        do {
            weather = try await fetchWeatherUseCase.execute()
            loadingState = .success
        } catch {
            loadingState = .error(error)
        }
    }
}
```

### 2. Domain Layer

**Responsabilidade:** Regras de negócio e modelos de domínio

**Componentes:**
- **Models:** Entidades do domínio (Weather, Camera, Alert)
- **UseCases:** Casos de uso (FetchWeatherUseCase)

**Regras:**
- Modelos independentes de framework
- UseCases encapsulam regras de negócio
- Não depende de outras camadas
- Pure Swift (sem UIKit/SwiftUI)

**Exemplo:**
```swift
struct Weather: Identifiable {
    let id: String
    let temperature: Double
    let condition: WeatherCondition
    // ... outros campos

    // Lógica de domínio
    var temperatureFormatted: String {
        "\(Int(temperature))°"
    }
}

final class FetchWeatherUseCase {
    private let repository: WeatherRepositoryProtocol

    func execute() async throws -> Weather {
        try await repository.fetchCurrentWeather()
    }
}
```

### 3. Data Layer

**Responsabilidade:** Acesso e transformação de dados

**Componentes:**
- **Repositories:** Implementação de acesso a dados
- **DTOs:** Data Transfer Objects (modelos de API)
- **Mocks:** Dados mockados para desenvolvimento

**Regras:**
- Repositories implementam protocols da camada Domain
- DTOs são convertidos para modelos de domínio
- Cache é gerenciado aqui
- Não expõe detalhes de implementação

**Exemplo:**
```swift
protocol WeatherRepositoryProtocol {
    func fetchCurrentWeather() async throws -> Weather
}

final class WeatherRepository: WeatherRepositoryProtocol {
    private let apiClient: APIClient
    private let cacheService: CacheService

    func fetchCurrentWeather() async throws -> Weather {
        // Tenta cache primeiro
        if let cached: Weather = cacheService.get(forKey: "weather") {
            return cached
        }

        // Busca da API
        let dto = try await apiClient.request(...)
        let weather = dto.toDomain()

        // Salva no cache
        cacheService.set(weather, forKey: "weather")

        return weather
    }
}
```

### 4. Infrastructure Layer

**Responsabilidade:** Detalhes técnicos e serviços externos

**Componentes:**
- **APIClient:** Cliente HTTP genérico
- **Services:** Cache, Location, etc.
- **Endpoints:** Definição de rotas
- **NetworkError:** Erros de rede

**Regras:**
- Genérico e reutilizável
- Sem lógica de negócio
- Pode ser substituído facilmente
- Tratamento de erros detalhado

**Exemplo:**
```swift
final class APIClient {
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        // Implementação genérica de networking
        // com tratamento de erros, timeout, etc.
    }
}
```

## 🔄 Fluxo de Dados

### Request Flow (Carregar Dados)

```
1. User Action
   └─> View (tap, appear, refresh)

2. ViewModel
   └─> loadData() async
       └─> loadingState = .loading

3. UseCase
   └─> execute() async throws
       └─> Aplica regras de negócio

4. Repository
   └─> fetchData() async throws
       └─> Verifica cache
       └─> Busca API se necessário

5. APIClient
   └─> request() async throws
       └─> URLSession
       └─> Retorna DTO

6. Repository (continuação)
   └─> Converte DTO → Domain Model
   └─> Salva no cache
   └─> Retorna modelo

7. UseCase (continuação)
   └─> Retorna modelo processado

8. ViewModel (continuação)
   └─> Atualiza @Published properties
   └─> loadingState = .success

9. View (continuação)
   └─> SwiftUI re-renderiza automaticamente
```

### Error Flow

```
1. Error ocorre em qualquer camada

2. Propagado via throw até ViewModel

3. ViewModel captura e atualiza estado
   └─> loadingState = .error(error)

4. View observa mudança e mostra ErrorView

5. User pode tentar novamente (retry)
   └─> Ciclo recomeça
```

## 🎯 Padrões de Design Utilizados

### 1. MVVM (Model-View-ViewModel)
- **View:** SwiftUI views
- **ViewModel:** ObservableObject com @Published
- **Model:** Domain models

### 2. Repository Pattern
- Abstrai fonte de dados
- Facilita testes e mudanças

### 3. Dependency Injection
- ViewModels recebem dependências no init
- Facilita testes com mocks

### 4. Protocol-Oriented Programming
- Repositories usam protocols
- Facilita testes e substituição

### 5. Observer Pattern
- SwiftUI + Combine (@Published)
- Reactive updates automáticos

### 6. Singleton (quando apropriado)
- CacheService.shared
- Uso controlado e justificado

## 🧪 Testabilidade

A arquitetura facilita testes em todos os níveis:

### Unit Tests - Domain Layer
```swift
func testWeatherTemperatureFormatting() {
    let weather = Weather(temperature: 28.5, ...)
    XCTAssertEqual(weather.temperatureFormatted, "28°")
}
```

### Unit Tests - UseCases
```swift
func testFetchWeatherUseCase() async throws {
    let mockRepo = MockWeatherRepository()
    let useCase = FetchWeatherUseCase(repository: mockRepo)

    let weather = try await useCase.execute()
    XCTAssertNotNil(weather)
}
```

### Unit Tests - ViewModels
```swift
@MainActor
func testHomeViewModelLoadData() async {
    let viewModel = HomeViewModel()
    await viewModel.loadData()

    XCTAssertNotNil(viewModel.weather)
}
```

### Integration Tests - Repositories
```swift
func testWeatherRepositoryWithRealAPI() async throws {
    let repo = WeatherRepository()
    let weather = try await repo.fetchCurrentWeather()

    XCTAssertNotNil(weather.id)
}
```

### UI Tests
```swift
func testHomeScreenShowsWeather() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.staticTexts["28°"].exists)
}
```

## 🔐 Princípios SOLID Aplicados

### Single Responsibility (SRP)
- Cada classe tem uma única responsabilidade
- FetchWeatherUseCase apenas busca clima
- WeatherRepository apenas gerencia dados de clima

### Open/Closed (OCP)
- Extensível via protocols
- Fechado para modificação direta

### Liskov Substitution (LSP)
- Implementações de repositório são intercambiáveis
- Mock e Real implementam mesmo protocol

### Interface Segregation (ISP)
- Protocols específicos por funcionalidade
- WeatherRepositoryProtocol, CamerasRepositoryProtocol

### Dependency Inversion (DIP)
- ViewModels dependem de abstrações (protocols)
- Não dependem de implementações concretas

## 🚀 Benefícios da Arquitetura

✅ **Testável:** Cada camada pode ser testada isoladamente

✅ **Manutenível:** Código organizado e responsabilidades claras

✅ **Escalável:** Fácil adicionar novas features

✅ **Flexível:** Mudanças em uma camada não afetam outras

✅ **Reutilizável:** Componentes genéricos e desacoplados

✅ **Legível:** Estrutura clara e intuitiva

## 🔄 Extensibilidade

### Adicionar Nova Funcionalidade

1. **Criar Model** (Domain/Models)
2. **Criar DTO** (Data/DTOs)
3. **Criar Endpoint** (Infra/Networking)
4. **Criar Repository** (Data/Repositories)
5. **Criar UseCase** (Domain/UseCases)
6. **Criar ViewModel** (Presentation/ViewModels)
7. **Criar View** (Presentation/Screens)

### Trocar Fonte de Dados

Basta implementar novo Repository:
```swift
// De API REST para GraphQL
final class GraphQLWeatherRepository: WeatherRepositoryProtocol {
    // Implementação GraphQL
}

// Injetar no UseCase
let useCase = FetchWeatherUseCase(
    repository: GraphQLWeatherRepository()
)
```

## 📚 Referências

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM in SwiftUI](https://www.swiftbysundell.com/articles/mvvm-in-swiftui/)
- [Protocol-Oriented Programming](https://developer.apple.com/videos/play/wwdc2015/408/)

---

**Esta arquitetura foi escolhida para garantir:**
- ✅ Qualidade de código
- ✅ Facilidade de manutenção
- ✅ Escalabilidade futura
- ✅ Testabilidade completa
