#!/bin/bash

arquivos=(
  "App/AppRouter.swift"
  "Presentation/ViewModels/HomeViewModel.swift"
  "Presentation/ViewModels/WeatherViewModel.swift"
  "Presentation/ViewModels/CamerasViewModel.swift"
  "Presentation/ViewModels/AlertsViewModel.swift"
  "Presentation/ViewModels/MapViewModel.swift"
  "Domain/Models/Camera.swift"
  "Domain/Models/Location.swift"
  "Domain/UseCases/FetchWeatherUseCase.swift"
)

echo "🚀 Adicionando 'import Combine' nos arquivos necessários..."

for arquivo in "${arquivos[@]}"; do
  if [ -f "$arquivo" ]; then
    if grep -q "import Combine" "$arquivo"; then
      echo "✅ $arquivo - já tem"
    else
      awk '/^import / && !done {print; print "import Combine"; done=1; next} 1' "$arquivo" > temp && mv temp "$arquivo"
      echo "✨ $arquivo - adicionado!"
    fi
  else
    echo "❌ $arquivo - não encontrado"
  fi
done

echo "🎉 Concluído!"
