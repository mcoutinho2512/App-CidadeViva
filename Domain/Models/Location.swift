//
//  Location.swift
//  CidadeViva
//
//  Modelo de domínio para localização
//

import Foundation
import CoreLocation

/// Representa uma localização geográfica
struct Location: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let city: String
    let state: String

    // MARK: - Computed Properties

    /// Endereço completo formatado
    var fullAddress: String {
        if let address = address {
            return "\(address), \(city) - \(state)"
        }
        return "\(city) - \(state)"
    }

    // MARK: - Equatable

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Region Helper

/// Regiões da cidade para filtros
enum CityRegion: String, CaseIterable, Identifiable {
    case norte = "Norte"
    case sul = "Sul"
    case leste = "Leste"
    case oeste = "Oeste"
    case centro = "Centro"
    case all = "Todas"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
