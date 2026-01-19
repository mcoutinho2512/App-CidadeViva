//
//  AppRouter.swift
//  CidadeViva
//
//  Gerenciamento de navegação e rotas do aplicativo
//

import SwiftUI

/// Gerenciador de rotas e navegação do aplicativo
final class AppRouter: ObservableObject {

    // MARK: - Published Properties

    @Published var navigationPath = NavigationPath()

    // MARK: - Navigation Methods

    /// Navega para uma rota específica
    func navigate(to route: Route) {
        navigationPath.append(route)
    }

    /// Volta para a tela anterior
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    /// Volta para a tela inicial (root)
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Routes

/// Enumeração de todas as rotas disponíveis no app
enum Route: Hashable {
    case home
    case weather
    case cameras
    case cameraDetail(Camera)
    case alerts
    case alertDetail(Alert)
    case map
    case settings
}
