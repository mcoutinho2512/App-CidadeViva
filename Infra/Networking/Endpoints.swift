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
    case events
    case eventsUpcoming
    case eventsFeatured
    case news
    case newsFeatured
    case pois
    case poisNearby(lat: Double, lng: Double)
    case navigationRoute

    /// Path do endpoint
    var path: String {
        switch self {
        case .weather:
            return "/weather/current"
        case .cameras:
            return "/cameras"
        case .alerts:
            return "/alerts"
        case .events:
            return "/events"
        case .eventsUpcoming:
            return "/events/upcoming"
        case .eventsFeatured:
            return "/events/featured"
        case .news:
            return "/news"
        case .newsFeatured:
            return "/news/featured"
        case .pois:
            return "/pois"
        case .poisNearby(let lat, let lng):
            return "/pois/nearby/?lat=\(lat)&lng=\(lng)"
        case .navigationRoute:
            return "/navigation/route"
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
        case .weather, .cameras, .alerts, .events, .eventsUpcoming, .eventsFeatured,
             .news, .newsFeatured, .pois, .poisNearby:
            return .get
        case .navigationRoute:
            return .post
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
