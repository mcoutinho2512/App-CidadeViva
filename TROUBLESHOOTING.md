# 🔧 Troubleshooting - CidadeViva

Guia completo de resolução de problemas comuns.

---

## 🚨 Problemas de Build

### Erro: "No such module 'SwiftUI'"

**Causa:** Deployment Target muito baixo

**Solução:**
1. Selecione o projeto no Xcode
2. Target > General
3. Minimum Deployments > iOS 15.0 ou superior

---

### Erro: "Module not found" ou "Use of unresolved identifier"

**Causa:** Arquivos não adicionados ao target ou ordem de compilação

**Solução:**
1. Clean Build Folder (⌘⇧K)
2. Selecione cada arquivo Swift no Project Navigator
3. File Inspector (⌘⌥1)
4. Verifique se "Target Membership" tem CidadeViva marcado
5. Delete Derived Data:
   ```
   ~/Library/Developer/Xcode/DerivedData
   ```
6. Restart Xcode
7. Build novamente (⌘B)

---

### Erro: "Cannot find 'Color' in scope" ou similar

**Causa:** Assets não configurados corretamente

**Solução:**
1. Verifique se `Assets.xcassets` está no projeto
2. File Inspector > Target Membership marcado
3. Abra Assets.xcassets
4. Confirme que existem:
   - PrimaryColor.colorset
   - SecondaryColor.colorset
   - AlertColor.colorset
   - WarningColor.colorset
5. Cada um deve ter um `Contents.json` válido

---

### Erro de compilação com "ObservableObject"

**Causa:** ViewModels não marcados como @MainActor ou problemas de concorrência

**Solução:**
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    // ...
}
```

Certifique-se que todos os ViewModels têm `@MainActor`.

---

### Erro: "Missing required module"

**Causa:** Imports faltando

**Solução:**
Adicione os imports necessários no topo de cada arquivo:

```swift
import SwiftUI        // Para Views
import Combine        // Para @Published
import MapKit         // Para MapView
import CoreLocation   // Para CLLocationCoordinate2D
import Foundation     // Para dados
```

---

## 🎨 Problemas de Interface

### Cores não aparecem / Ficam em branco

**Causa:** ColorSets não configurados ou nome errado

**Solução:**
1. Verifique nomes exatos em `Assets.xcassets`:
   - PrimaryColor (não primary-color)
   - SecondaryColor
   - AlertColor
   - WarningColor

2. Use exatamente assim no código:
```swift
Color("PrimaryColor")  // Correto
Color("primary")       // Errado
```

3. Verifique Contents.json de cada ColorSet:
```json
{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.000",
          "green": "0.478",
          "blue": "1.000",
          "alpha": "1.000"
        }
      }
    }
  ]
}
```

---

### Dark Mode não funciona

**Causa:** Cores fixas em vez de adapativas

**Solução:**
1. Use Color("PrimaryColor") em vez de Color.blue
2. Use Color(UIColor.systemBackground) para fundos
3. Verifique ColorSets com variante dark:

```json
{
  "appearances": [
    {
      "appearance": "luminosity",
      "value": "dark"
    }
  ]
}
```

---

### Layout quebrado em iPad

**Causa:** Tamanhos fixos ou constraints incorretas

**Solução:**
Use frame com maxWidth:
```swift
.frame(maxWidth: .infinity)  // Responsivo
```

Em vez de:
```swift
.frame(width: 375)  // Fixo - evitar
```

---

### TabBar badge não aparece

**Causa:** ViewModel não publicando valor corretamente

**Solução:**
```swift
// No ViewModel
@Published var activeAlertsCount: Int = 0

// Na View
.badge(viewModel.activeAlertsCount)
```

Certifique-se que o valor é atualizado em `loadData()`.

---

## 🗺️ Problemas com Mapa

### Mapa não carrega / Tela em branco

**Causa:** MapKit não importado ou região inválida

**Solução:**
1. Verifique import:
```swift
import MapKit
```

2. Verifique região inicial:
```swift
MKCoordinateRegion(
    center: CLLocationCoordinate2D(
        latitude: -23.5505,  // Coordenadas válidas
        longitude: -46.6333
    ),
    span: MKCoordinateSpan(
        latitudeDelta: 0.05,
        longitudeDelta: 0.05
    )
)
```

---

### Marcadores não aparecem no mapa

**Causa:** Coordenadas inválidas ou items vazios

**Solução:**
1. Verifique dados mockados em `MockData.swift`
2. Certifique-se que cameras/alerts têm coordenadas:
```swift
Camera(
    coordinate: CLLocationCoordinate2D(
        latitude: -23.5617,   // Não pode ser 0.0
        longitude: -46.6562   // Não pode ser 0.0
    )
)
```

3. Verifique se toggles estão ativos:
```swift
@Published var showCameras: Bool = true
@Published var showAlerts: Bool = true
```

---

### "Location permission denied"

**Causa:** Info.plist sem descrição de permissão

**Solução:**
1. Abra Info.plist
2. Adicione:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para mostrar informações da sua região.</string>
```

3. No Simulador: Features > Location > Custom Location

---

## 📡 Problemas de Dados

### Dados não carregam / Tela fica em loading infinito

**Causa:** Mock data não configurado ou erro no UseCase

**Solução:**
1. Verifique flag em `AppConfiguration.swift`:
```swift
static let enableMockData = true  // Deve ser true
```

2. Verifique console do Xcode para erros

3. Adicione debug print nos ViewModels:
```swift
func loadData() async {
    print("🔍 Loading data...")
    loadingState = .loading

    do {
        let data = try await useCase.execute()
        print("✅ Data loaded: \(data)")
        loadingState = .success
    } catch {
        print("❌ Error: \(error)")
        loadingState = .error(error)
    }
}
```

---

### "Task was cancelled" error

**Causa:** Task cancelada antes de completar

**Solução:**
Use `.task` em vez de `.onAppear`:
```swift
.task {
    await viewModel.loadData()
}
```

Não use:
```swift
.onAppear {
    Task {
        await viewModel.loadData()
    }
}
```

---

### Cache não funciona

**Causa:** CacheService não salvando ou chave errada

**Solução:**
1. Verifique chaves em `CacheService.CacheKey`:
```swift
extension CacheService {
    enum CacheKey {
        static let weather = "cache.weather"
        static let cameras = "cache.cameras"
        static let alerts = "cache.alerts"
    }
}
```

2. Use chave correta no Repository:
```swift
cacheService.set(weather, forKey: CacheService.CacheKey.weather)
```

3. Para limpar cache:
```swift
CacheService.shared.clearAll()
```

---

## 🔄 Problemas de Navegação

### TabBar não aparece

**Causa:** TabView não configurado corretamente

**Solução:**
Verifique estrutura em `CidadeVivaApp.swift`:
```swift
TabView(selection: $selectedTab) {
    NavigationStack {
        HomeView()
    }
    .tabItem {
        Label("Início", systemImage: "house.fill")
    }
    .tag(0)
    // ... outras tabs
}
```

---

### Navegação entre telas não funciona

**Causa:** NavigationStack faltando ou mal configurado

**Solução:**
Cada tab deve ter seu próprio NavigationStack:
```swift
NavigationStack {
    HomeView()
}
```

---

## ⚡ Problemas de Performance

### App lento / Laggy

**Causa:** Operações síncronas na main thread

**Solução:**
1. Use async/await para operações pesadas:
```swift
func loadData() async {
    // Operações assíncronas
}
```

2. Marque ViewModels com @MainActor:
```swift
@MainActor
final class HomeViewModel: ObservableObject { }
```

---

### Animações não suaves

**Causa:** Updates muito frequentes ou sem animação

**Solução:**
Use `withAnimation`:
```swift
withAnimation {
    region.center = camera.coordinate
}
```

---

## 📱 Problemas no Simulador

### Simulador não inicia

**Causa:** Simulador antigo ou corrompido

**Solução:**
1. Xcode > Window > Devices and Simulators
2. Delete simulador problemático
3. Crie novo simulador
4. Ou via terminal:
```bash
xcrun simctl erase all
```

---

### App crashea ao abrir no simulador

**Causa:** Permissões ou configurações faltando

**Solução:**
1. Verifique console do Xcode para stack trace
2. Verifique Info.plist
3. Delete app do simulador:
   - Segure ícone no simulador
   - Delete App
   - Build & Run novamente

---

### "Scheme not found"

**Causa:** Scheme não criado ou desabilitado

**Solução:**
1. Product > Scheme > Manage Schemes
2. Certifique-se que CidadeViva está marcado como "Shared"
3. Ou crie novo scheme

---

## 🧪 Problemas Específicos por Tela

### HomeView - Cards não aparecem

**Checklist:**
- [ ] ViewModel inicializado corretamente
- [ ] `.task { await viewModel.loadData() }` presente
- [ ] MockData retornando dados válidos
- [ ] LoadingState mudando corretamente

---

### WeatherView - Temperatura não formata

**Checklist:**
- [ ] Weather model tem computed property `temperatureFormatted`
- [ ] Temperatura é Double válido
- [ ] String interpolation correto: `"\(Int(temperature))°"`

---

### CamerasView - Filtros não funcionam

**Checklist:**
- [ ] `applyFilters()` é chamado após mudar filtro
- [ ] `filteredCameras` é usado na lista (não `cameras`)
- [ ] Binding correto nos Pickers

---

### AlertsView - Badge não atualiza

**Checklist:**
- [ ] `activeAlertsCount` é computed property
- [ ] Retorna `alerts.filter { $0.isActive }.count`
- [ ] ViewModel é @ObservedObject na View

---

### MapView - Annotations não aparecem

**Checklist:**
- [ ] Cameras/Alerts têm coordenadas válidas
- [ ] `showCameras` e `showAlerts` são true
- [ ] `mapAnnotations` computed property retorna items
- [ ] Região do mapa cobre as coordenadas

---

## 🔍 Debug Tips

### Habilitar Logging

Em `AppConfiguration.swift`:
```swift
static let enableNetworkLogging = true
```

Logs aparecerão no console:
- 🌐 Network requests
- ☁️ Cache hits
- 📹 Data loading
- ❌ Errors

---

### Verificar Estado do ViewModel

Adicione print statements:
```swift
func loadData() async {
    print("📊 Current state: \(loadingState)")
    // ... resto do código
    print("📊 New state: \(loadingState)")
}
```

---

### Verificar Chamadas de API Mock

Em `APIClient.swift`, verifique logs:
```
🔶 [APIClient] Using MOCK data for endpoint: /weather/current
```

Se não aparecer, `enableMockData` está false.

---

## 🆘 Últimos Recursos

### Reiniciar Tudo

```bash
# 1. Limpar build
⌘⇧K

# 2. Delete Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 3. Reiniciar Xcode

# 4. Limpar simulador
xcrun simctl erase all

# 5. Build limpo
⌘B
```

---

### Criar Projeto do Zero

Se nada funcionar:

1. Criar novo projeto iOS App
2. Configurar corretamente (iOS 15.0, SwiftUI)
3. Adicionar arquivos um por um
4. Build após cada grupo de arquivos
5. Identificar onde ocorre erro

---

### Verificar Versões

```
Xcode: 15.0+
macOS: Sonoma 14.0+
iOS Deployment: 15.0+
Swift: 5.9+
```

---

## 📞 Checklist Final

Antes de pedir ajuda, verifique:

- [ ] Xcode atualizado
- [ ] Deployment Target correto (iOS 15.0)
- [ ] Todos arquivos no target
- [ ] Assets.xcassets configurado
- [ ] Info.plist válido
- [ ] enableMockData = true
- [ ] Console do Xcode verificado
- [ ] Build limpo executado
- [ ] Simulador reiniciado

---

**90% dos problemas são resolvidos com:**
1. Clean Build (⌘⇧K)
2. Delete Derived Data
3. Restart Xcode
4. Verificar que arquivos estão no target

**Boa sorte! 🚀**
