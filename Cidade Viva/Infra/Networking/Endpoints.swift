//
//  Endpoints.swift
//  CidadeViva
//
//  Definição de endpoints da API
//

import Foundation

/// Endpoints disponíveis na API
enum Endpoint {
    case weather
    case cameras
    case alerts

    /// Path do endpoint
    var path: String {
        switch self {
        case .weather:
            return "/weather/current"
        case .cameras:
            return "/cameras"
        case .alerts:
            return "/alerts"
        }
    }

    /// URL completa do endpoint
    var url: URL? {
        let baseURL = AppConfiguration.API.fullBaseURL
        return URL(string: baseURL + path)
    }

    /// Método HTTP
    var method: HTTPMethod {
        switch self {
        case .weather, .cameras, .alerts:
            return .get
        }
    }
}

/// Métodos HTTP suportados
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
