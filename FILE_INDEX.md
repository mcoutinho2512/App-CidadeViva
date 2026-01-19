# 📑 Índice de Arquivos - CidadeViva

Guia completo de todos os arquivos do projeto com suas responsabilidades.

---

## 📱 APP LAYER (3 arquivos)

### App/CidadeVivaApp.swift
**Função:** Entry point do aplicativo
- Configuração inicial
- TabView com 5 abas
- Injeção de ViewModels
- Configuração de aparência global

### App/AppRouter.swift
**Função:** Gerenciamento de navegação
- NavigationPath
- Rotas do app
- Métodos de navegação (push, pop, popToRoot)

### App/AppConfiguration.swift
**Função:** Configurações centralizadas
- URLs de API
- Feature flags (enableMockData)
- Constantes de UI
- Configurações de cache/mapa

---

## 🎨 PRESENTATION LAYER

### 📺 Screens (5 arquivos)

#### Presentation/Screens/HomeView.swift
**Função:** Tela principal / Dashboard
- Cards de resumo (clima, câmeras, alertas)
- Pull to refresh
- Estados: loading, success, error
- Última atualização

#### Presentation/Screens/WeatherView.swift
**Função:** Detalhes do clima
- Temperatura em destaque
- Ícone do clima (SF Symbol)
- Detalhes: umidade, vento
- Cards informativos

#### Presentation/Screens/CamerasView.swift
**Função:** Lista de câmeras
- Lista com filtros
- Busca por nome/região
- Estatísticas (online/offline)
- Filtro por região e status
- Sheet com opções de filtro

#### Presentation/Screens/AlertsView.swift
**Função:** Lista de alertas
- Alertas ordenados por severidade
- Filtros por tipo/severidade
- Toggle "Apenas Ativos"
- Cards coloridos por severidade
- Estatísticas (ativos/críticos)

#### Presentation/Screens/MapView.swift
**Função:** Mapa interativo
- MapKit com pins de câmeras/alertas
- Callouts ao clicar
- Botão de localização do usuário
- Controles de visibilidade
- Legenda (sheet)

---

### 🧠 ViewModels (5 arquivos)

#### Presentation/ViewModels/HomeViewModel.swift
**Função:** Lógica da tela Home
- Carrega dados de clima, câmeras e alertas em paralelo
- Gerencia estados de loading
- Pull to refresh
- Última atualização
**Dependências:** 3 UseCases

#### Presentation/ViewModels/WeatherViewModel.swift
**Função:** Lógica da tela Weather
- Carrega dados climáticos
- Gerencia estado
- Refresh
**Dependências:** FetchWeatherUseCase

#### Presentation/ViewModels/CamerasViewModel.swift
**Função:** Lógica da tela Câmeras
- Carrega lista de câmeras
- Aplica filtros (região, status, busca)
- Estatísticas (online/offline)
- Gerencia filtros ativos
**Dependências:** FetchCamerasUseCase

#### Presentation/ViewModels/AlertsViewModel.swift
**Função:** Lógica da tela Alertas
- Carrega lista de alertas
- Filtros (tipo, severidade)
- Toggle apenas ativos
- Contador de alertas
**Dependências:** FetchAlertsUseCase

#### Presentation/ViewModels/MapViewModel.swift
**Função:** Lógica da tela Mapa
- Carrega câmeras e alertas para mapa
- Gerencia região do mapa
- Seleção de marcadores
- Toggles de visibilidade
- Centralização (camera, alert, user)
**Dependências:** 2 UseCases + LocationService

---

### 🧩 Components (4 arquivos)

#### Presentation/Components/InfoCard.swift
**Função:** Card de informação reutilizável
- Ícone + título + valor + subtítulo
- Ação opcional (tap)
- Estilo consistente

#### Presentation/Components/LoadingView.swift
**Função:** Estado de carregamento
- ProgressView + mensagem
- Usado em todas as telas

#### Presentation/Components/ErrorView.swift
**Função:** Estado de erro
- Ícone + mensagem de erro
- Sugestão de recuperação
- Botão "Tentar Novamente"

#### Presentation/Components/CardStyle.swift
**Função:** Modificador de estilo de card
- Background, corner radius, shadow
- ViewModifier reutilizável
- `.cardStyle()` extension

---

## 🎯 DOMAIN LAYER

### 📦 Models (4 arquivos)

#### Domain/Models/Weather.swift
**Função:** Modelo de clima
- Propriedades: temperatura, condição, umidade, vento
- WeatherCondition enum
- Computed properties formatados
- SF Symbol para cada condição

#### Domain/Models/Camera.swift
**Função:** Modelo de câmera
- Propriedades: nome, região, status, coordenadas
- CameraStatus enum (online/offline/maintenance)
- Cores por status
- Ícones SF Symbol

#### Domain/Models/Alert.swift
**Função:** Modelo de alerta
- Propriedades: tipo, severidade, título, descrição
- AlertType enum (trânsito, clima, etc)
- AlertSeverity enum (baixa a crítica)
- Cores e prioridades

#### Domain/Models/Location.swift
**Função:** Modelo de localização
- CLLocationCoordinate2D helpers
- CityRegion enum (Norte, Sul, etc)
- Formatação de endereços

---

### 🎬 UseCases (3 arquivos)

#### Domain/UseCases/FetchWeatherUseCase.swift
**Função:** Buscar dados climáticos
- execute() -> Weather
- Chamada ao WeatherRepository

#### Domain/UseCases/FetchCamerasUseCase.swift
**Função:** Buscar lista de câmeras
- execute() -> [Camera]
- Filtros por região/status
- Ordenação

#### Domain/UseCases/FetchAlertsUseCase.swift
**Função:** Buscar lista de alertas
- execute() -> [Alert]
- executeActiveOnly()
- Filtros por tipo/severidade
- Ordenação por prioridade

---

## 💾 DATA LAYER

### 🗄️ Repositories (3 arquivos)

#### Data/Repositories/WeatherRepository.swift
**Função:** Acesso a dados de clima
- Implementa WeatherRepositoryProtocol
- Integração com APIClient
- Gerenciamento de cache
- Conversão DTO → Domain

#### Data/Repositories/CamerasRepository.swift
**Função:** Acesso a dados de câmeras
- Implementa CamerasRepositoryProtocol
- Cache + API
- Array de câmeras

#### Data/Repositories/AlertsRepository.swift
**Função:** Acesso a dados de alertas
- Implementa AlertsRepositoryProtocol
- Cache + API
- Array de alertas

---

### 📋 DTOs (3 arquivos)

#### Data/DTOs/WeatherDTO.swift
**Função:** Data Transfer Object de clima
- WeatherResponseDTO (resposta da API)
- WeatherDataDTO (dados do clima)
- Método toDomain() para conversão
- Exemplo de JSON comentado

#### Data/DTOs/CameraDTO.swift
**Função:** Data Transfer Object de câmera
- CamerasResponseDTO
- CameraDataDTO
- Array conversion helpers
- snake_case ↔ camelCase

#### Data/DTOs/AlertDTO.swift
**Função:** Data Transfer Object de alerta
- AlertsResponseDTO
- AlertDataDTO
- Array conversion
- Tratamento de coordenadas opcionais

---

### 🎭 Mocks (1 arquivo)

#### Data/Mocks/MockData.swift
**Função:** Dados mockados para desenvolvimento
- mockWeather() - 1 registro
- mockCameras() - 6 registros
- mockAlerts() - 5 registros
- Versões DTO para API mock
- Dados realistas de São Paulo

---

## 🔌 INFRASTRUCTURE LAYER

### 🌐 Networking (3 arquivos)

#### Infra/Networking/APIClient.swift
**Função:** Cliente HTTP genérico
- request<T: Decodable>() async throws
- Suporte a mock e API real
- Tratamento de erros completo
- Timeout configurável
- Logging em DEBUG
- Delay simulado para mocks

#### Infra/Networking/Endpoints.swift
**Função:** Definição de rotas
- Endpoint enum (weather, cameras, alerts)
- HTTPMethod enum
- URLs construídas automaticamente

#### Infra/Networking/NetworkError.swift
**Função:** Tipos de erro de rede
- NetworkError enum
- LocalizedError
- Mensagens em PT-BR
- Sugestões de recuperação

---

### ⚙️ Services (2 arquivos)

#### Infra/Services/CacheService.swift
**Função:** Cache em memória
- Singleton (shared)
- Generic get/set
- Expiração automática (10min)
- Thread-safe (DispatchQueue)
- Limpeza manual/automática
- CacheKey predefinidos

#### Infra/Services/LocationService.swift
**Função:** Serviço de localização
- CLLocationManager wrapper
- @Published userLocation
- Permissões
- ObservableObject
- Start/stop updates

---

## 📦 RESOURCES

### 📄 Info.plist
**Função:** Configurações do app
- Bundle ID: com.cidadeviva.ios
- Display Name: CidadeViva
- Permissões de localização
- Scene configuration
- Orientações suportadas
- Localização: pt_BR

### 🎨 Assets.xcassets

#### PrimaryColor.colorset/Contents.json
**Função:** Cor primária (Azul #007AFF)
- Variante light: #007AFF
- Variante dark: #0A95FF

#### SecondaryColor.colorset/Contents.json
**Função:** Cor secundária (Verde #34C759)
- Status positivo
- Light/Dark variants

#### AlertColor.colorset/Contents.json
**Função:** Cor de alerta (Vermelho #FF3B30)
- Erros e alertas críticos
- Light/Dark variants

#### WarningColor.colorset/Contents.json
**Função:** Cor de aviso (Laranja #FF9500)
- Avisos e média prioridade
- Light/Dark variants

#### AppIcon.appiconset/Contents.json
**Função:** Configuração do ícone
- Todos os tamanhos iPhone/iPad
- 1024x1024 para App Store

---

## 📚 DOCUMENTAÇÃO (4 arquivos)

### README.md
**Conteúdo:**
- Visão geral do projeto
- Funcionalidades
- Arquitetura
- Como executar
- Configuração
- Design system
- Features futuras

### BUILD_INSTRUCTIONS.md
**Conteúdo:**
- Guia passo a passo de setup no Xcode
- Configurações necessárias
- Checklist de verificação
- Troubleshooting de build
- Testando funcionalidades

### ARCHITECTURE.md
**Conteúdo:**
- Diagrama de camadas
- Responsabilidades
- Fluxo de dados
- Padrões de design
- SOLID principles
- Testabilidade
- Extensibilidade

### TROUBLESHOOTING.md
**Conteúdo:**
- Problemas comuns
- Soluções detalhadas
- Debug tips
- Checklist final

### PROJECT_SUMMARY.md
**Conteúdo:**
- Estatísticas do projeto
- Estrutura completa
- Features implementadas
- Próximos passos

### FILE_INDEX.md (este arquivo)
**Conteúdo:**
- Índice completo de arquivos
- Descrição de cada arquivo
- Responsabilidades

---

## 📊 Estatísticas

**Total de Arquivos:** 47

**Por Tipo:**
- Swift: 36 arquivos
- Markdown: 5 arquivos
- JSON: 6 arquivos (Assets + Info.plist)

**Por Camada:**
- App: 3
- Presentation: 14 (5 views + 5 viewmodels + 4 components)
- Domain: 7 (4 models + 3 usecases)
- Data: 7 (3 repos + 3 dtos + 1 mock)
- Infrastructure: 5 (3 network + 2 services)
- Resources: 6 (1 plist + 5 assets)
- Docs: 5

**Linhas de Código (aprox):**
- Total: ~3,500 linhas
- Média por arquivo: ~100 linhas
- Comentários: ~30%

---

## 🎯 Navegação Rápida

**Precisa alterar:**
- Cores → Resources/Assets.xcassets/[Cor].colorset
- Mock Data → Data/Mocks/MockData.swift
- API URLs → App/AppConfiguration.swift
- Modelos → Domain/Models/
- UI → Presentation/Screens/
- Lógica → Presentation/ViewModels/

**Precisa adicionar:**
- Nova tela → Presentation/Screens/ + ViewModel
- Novo modelo → Domain/Models/
- Nova API → Infra/Networking/Endpoints.swift
- Novo serviço → Infra/Services/

---

**Todos os arquivos estão documentados internamente com comentários em português!**
