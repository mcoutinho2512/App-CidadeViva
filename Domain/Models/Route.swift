//
//  Route.swift
//  CidadeViva
//
//  Modelo de domínio para rotas de navegação
//

import Foundation
import CoreLocation

/// Representa uma rota calculada
struct Route: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    let origin: RoutePoint
    let destination: RoutePoint
    let mode: RouteMode
    let distance: Double // em metros
    let duration: Double // em segundos
    let coordinates: [CLLocationCoordinate2D]
    let instructions: [RouteInstruction]?
    let createdAt: Date

    // MARK: - Computed Properties

    /// Distância formatada
    var distanceFormatted: String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            let km = distance / 1000
            return String(format: "%.1f km", km)
        }
    }

    /// Duração formatada
    var durationFormatted: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(remainingMinutes)min"
        }
    }

    /// Resumo da rota
    var summary: String {
        "\(distanceFormatted) • \(durationFormatted)"
    }

    // MARK: - Equatable

    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Route Point

/// Representa um ponto na rota (origem ou destino)
struct RoutePoint: Equatable {
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: RoutePoint, rhs: RoutePoint) -> Bool {
        lhs.name == rhs.name &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - Route Mode

/// Modos de transporte para rota
enum RouteMode: String, Codable, CaseIterable, Identifiable {
    case walking = "walking"
    case driving = "driving"
    case cycling = "cycling"

    var id: String { rawValue }

    /// Descrição legível
    var description: String {
        switch self {
        case .walking:
            return "A pé"
        case .driving:
            return "De carro"
        case .cycling:
            return "De bicicleta"
        }
    }

    /// Ícone SF Symbol
    var iconName: String {
        switch self {
        case .walking:
            return "figure.walk"
        case .driving:
            return "car.fill"
        case .cycling:
            return "bicycle"
        }
    }

    /// Cor do modo
    var colorName: String {
        switch self {
        case .walking:
            return "SecondaryColor"
        case .driving:
            return "PrimaryColor"
        case .cycling:
            return "WarningColor"
        }
    }
}

// MARK: - Route Instruction

/// Instrução de navegação turn-by-turn
struct RouteInstruction: Identifiable, Equatable {
    let id: String
    let text: String
    let distance: Double
    let duration: Double
    let coordinate: CLLocationCoordinate2D
    let type: InstructionType

    var distanceFormatted: String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            let km = distance / 1000
            return String(format: "%.1f km", km)
        }
    }

    static func == (lhs: RouteInstruction, rhs: RouteInstruction) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Instruction Type

enum InstructionType: String, Codable {
    case start = "start"
    case turnLeft = "turn_left"
    case turnRight = "turn_right"
    case straight = "straight"
    case arrive = "arrive"
    case other = "other"

    var iconName: String {
        switch self {
        case .start:
            return "location.fill"
        case .turnLeft:
            return "arrow.turn.up.left"
        case .turnRight:
            return "arrow.turn.up.right"
        case .straight:
            return "arrow.up"
        case .arrive:
            return "mappin.circle.fill"
        case .other:
            return "arrow.forward"
        }
    }
}
