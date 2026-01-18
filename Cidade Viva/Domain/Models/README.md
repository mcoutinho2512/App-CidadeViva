# 🏙️ CidadeViva

<div align="center">
  
  ![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
  ![License](https://img.shields.io/badge/license-MIT-black.svg)

  **App de monitoramento urbano inteligente para o Rio de Janeiro**
  
  *Clima em tempo real • Câmeras de tráfego • Alertas urbanos • Mapa interativo*

</div>

---

## 📱 Sobre o Projeto

**CidadeViva** é um aplicativo iOS moderno que centraliza informações essenciais sobre a cidade do Rio de Janeiro em uma interface premium e intuitiva. O app oferece:

- 🌡️ **Clima em tempo real** com previsões detalhadas
- 📹 **6 câmeras** de monitoramento estrategicamente posicionadas
- 🚨 **Sistema de alertas** urbanos com diferentes níveis de severidade
- 🗺️ **Mapa interativo** com visualização de câmeras e alertas
- 🎨 **Design premium** com glassmorphism e animações fluidas

---

## ✨ Características

### 🎨 Design Premium
- **Glassmorphism** em todos os cards e componentes
- **Gradientes vibrantes** que mudam com condições climáticas
- **Animações fluidas** com spring physics
- **Dark mode first** com paleta de cores moderna
- **Micro-interações** em toda a interface

### 🏗️ Arquitetura
- **MVVM** (Model-View-ViewModel)
- **Clean Architecture** com separação de camadas
- **Swift Concurrency** (async/await)
- **Combine** para reactive programming
- **Dependency Injection** para testabilidade

### 📍 Localizações do Rio de Janeiro

#### Câmeras de Monitoramento
1. **Avenida Atlântica - Copacabana** (Zona Sul)
2. **Linha Vermelha - Fundão** (Zona Norte)
3. **Túnel Rebouças - Lagoa** (Zona Sul)
4. **Avenida Brasil - Penha** (Zona Oeste)
5. **Ponte Rio-Niterói** (Centro)
6. **Avenida Niemeyer - Leblon** (Zona Sul)

#### Alertas Urbanos
- Congestionamentos em vias principais
- Condições climáticas adversas
- Eventos programados
- Obras e manutenção
- Emergências

---

## 🚀 Começando

### Pré-requisitos

- **macOS** Sonoma (14.0) ou superior
- **Xcode** 15.0 ou superior
- **iOS** 15.0 ou superior
- Conhecimento básico de Swift e SwiftUI

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/mcoutinho2512/App-CidadeViva.git
cd App-CidadeViva
```

2. **Abra o projeto no Xcode**
```bash
open "Cidade Viva.xcodeproj"
```

3. **Selecione o simulador ou dispositivo**
   - iPhone 14 Pro ou superior recomendado
   - iOS 15.0 mínimo

4. **Build e Execute**
```bash
Command + R
```

---

## 🏛️ Estrutura do Projeto

```
CidadeViva/
├── Domain/              # Camada de domínio
│   ├── Models/          # Modelos de dados
│   │   ├── Weather.swift
│   │   ├── Camera.swift
│   │   ├── Alert.swift
│   │   └── Location.swift
│   └── UseCases/        # Casos de uso
│
├── Data/                # Camada de dados
│   ├── DTOs/            # Data Transfer Objects
│   ├── Repositories/    # Implementação de repositórios
│   └── Services/        # Serviços (API, Cache, Location)
│
├── Presentation/        # Camada de apresentação
│   ├── Screens/         # Telas principais
│   │   ├── HomeView.swift
│   │   ├── WeatherView.swift
│   │   ├── CamerasView.swift
│   │   ├── AlertsView.swift
│   │   └── MapView.swift
│   ├── ViewModels/      # ViewModels
│   └── Components/      # Componentes reutilizáveis
│       ├── GlassCard.swift
│       └── DesignSystemV2.swift
│
├── Core/                # Funcionalidades core
│   ├── Configuration/   # Configurações
│   ├── Networking/      # Camada de rede
│   └── Utils/           # Utilitários
│
└── Resources/           # Recursos
    ├── Assets.xcassets
    └── MockData.swift
```

---

## 🎨 Design System V2

O app utiliza um design system completo e moderno:

### Cores Principais
```swift
Background Dark:  #0A0E27
Background Card:  #141B34
Primary Start:    #667EEA
Primary End:      #764BA2
Accent Cyan:      #00D9FF
Success Neon:     #00E5B8
Error Vibrant:    #FF3B6D
Warning Gold:     #FFB800
```

### Gradientes
- **Primary**: Roxo → Azul
- **Sunrise**: Rosa → Laranja
- **Ocean**: Azul → Ciano
- **Forest**: Verde → Azul
- **Fire**: Vermelho → Laranja

### Componentes Premium
- `GlassCard` - Card com glassmorphism
- `MiniGlassCard` - Stats compactos
- `HeroWeatherCard` - Card climático imersivo
- `CameraStatusCard` - Status de câmera
- `AlertCardPremium` - Alertas com gradiente

### Animações
- **Staggered Appearance** - Aparição em sequência
- **Bounce Press** - Feedback tátil visual
- **Animated Counters** - Números animados
- **Pulse** - Animação pulsante
- **Glow** - Efeito de brilho
- **Shimmer** - Loading skeleton

---

## 📚 Funcionalidades Detalhadas

### 🌡️ Clima
- Temperatura atual e sensação térmica
- Condição climática com ícone animado
- Umidade e velocidade do vento
- Gradiente dinâmico baseado no clima
- Temperatura em fonte gigante (80pt)
- Última atualização relativa

### 📹 Câmeras
- 6 câmeras estratégicas do Rio
- Status em tempo real (Online/Offline/Manutenção)
- Indicador pulsante para câmeras ativas
- Filtros por região e status
- Busca por nome ou localização
- Mapa de coordenadas reais

### 🚨 Alertas
- 5 tipos de alertas (Trânsito, Clima, Segurança, etc.)
- 4 níveis de severidade (Baixa, Média, Alta, Crítica)
- Badges visuais com gradiente
- Filtros por tipo e severidade
- Timestamp relativo
- Coordenadas no mapa

### 🗺️ Mapa
- Centralizado no Rio de Janeiro
- Visualização de todas as câmeras
- Pins de alertas ativos
- Zoom interativo
- Callouts com informações
- Toggle de visibilidade

---

## 🛠️ Tecnologias Utilizadas

### Frameworks Apple
- **SwiftUI** 3.0+ - Interface declarativa
- **MapKit** - Mapas e localização
- **CoreLocation** - Serviços de localização
- **Combine** - Reactive programming
- **Foundation** - Funcionalidades base

### Padrões e Práticas
- **MVVM** - Arquitetura
- **Clean Architecture** - Separação de camadas
- **Repository Pattern** - Abstração de dados
- **Use Cases** - Lógica de negócio
- **Dependency Injection** - Testabilidade
- **Protocol-Oriented** - Design modular

### Recursos Modernos
- **Swift Concurrency** (async/await, actors)
- **Symbol Effects** (iOS 17+)
- **Content Transitions** (iOS 16+)
- **.ultraThinMaterial** - Blur effects
- **@MainActor** - Thread safety

---

## 📖 Documentação Adicional

O projeto inclui documentação completa:

- 📄 `REDESIGN_SUMMARY.md` - Overview do redesign premium
- 📄 `CORRECTIONS_APPLIED.md` - Histórico de correções
- 📄 `CIDADE_MUDANCA_RIO.md` - Mudança para Rio de Janeiro
- 📄 `MAPA_RIO_ATUALIZADO.md` - Atualização do mapa
- 📄 `SCROLL_CORRIGIDO.md` - Correção de scroll
- 📄 `FINAL_STATUS.md` - Status final do projeto

---

## 🗺️ Roadmap

### Versão Atual (1.0.0)
- ✅ Design premium com glassmorphism
- ✅ Clima do Rio de Janeiro
- ✅ 6 câmeras de monitoramento
- ✅ 5 alertas urbanos
- ✅ Mapa interativo
- ✅ Animações fluidas

### Próximas Features (1.1.0)
- [ ] Integração com API real
- [ ] Notificações push para alertas
- [ ] Widgets para iOS
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts
- [ ] Dados históricos

### Futuro (2.0.0)
- [ ] Machine Learning para previsões
- [ ] Realidade Aumentada no mapa
- [ ] Integração com transporte público
- [ ] Modo offline completo
- [ ] Customização de alertas
- [ ] Multi-cidades

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos:

1. **Fork** o projeto
2. Crie uma **branch** para sua feature (`git checkout -b feature/NovaFeature`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. **Push** para a branch (`git push origin feature/NovaFeature`)
5. Abra um **Pull Request**

### Diretrizes
- Mantenha o código limpo e documentado
- Siga os padrões de arquitetura existentes
- Adicione testes quando possível
- Atualize a documentação

---

## 🐛 Reportando Bugs

Encontrou um bug? Abra uma [issue](https://github.com/mcoutinho2512/App-CidadeViva/issues) com:

- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs atual
- Screenshots (se aplicável)
- Versão do iOS e dispositivo

---

## 📄 Licença

Este projeto está sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Magnum Coutinho**

- GitHub: [@mcoutinho2512](https://github.com/mcoutinho2512)
- LinkedIn: [Seu LinkedIn]
- Email: [Seu Email]

---

## 🙏 Agradecimentos

- Apple por frameworks incríveis
- Comunidade SwiftUI
- Inspiração: Apple Weather, Stripe, Arc Browser, Linear

---

## 📸 Screenshots

### Home
Interface principal com clima e quick stats

### Clima
Card imersivo com gradiente dinâmico

### Câmeras
Monitoramento em tempo real

### Alertas
Sistema de notificações urbanas

### Mapa
Visualização geográfica interativa

---

<div align="center">

**Feito com ❤️ usando SwiftUI**

⭐ Se você gostou do projeto, dê uma estrela!

</div>
