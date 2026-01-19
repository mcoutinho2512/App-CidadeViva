//
//  PointOfInterest.swift
//  CidadeViva
//
//  Modelo de domínio para pontos de interesse
//

import Foundation
import CoreLocation

/// Representa um ponto de interesse (POI) na cidade
struct PointOfInterest: Identifiable, Hashable {

    // MARK: - Properties

    let id: String
    let name: String
    let description: String?
    let type: POIType
    let address: String
    let coordinate: CLLocationCoordinate2D
    let phone: String?
    let email: String?
    let website: String?
    let imageURL: String?
    let openingHours: String?
    let rating: Double?
    let city: String

    // MARK: - Computed Properties

    /// Endereço completo formatado
    var fullAddress: String {
        address
    }

    /// Telefone formatado para ligação
    var phoneURL: URL? {
        guard let phone = phone else { return nil }
        let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return URL(string: "tel:\(cleanPhone)")
    }

    /// Email formatado para envio
    var emailURL: URL? {
        guard let email = email else { return nil }
        return URL(string: "mailto:\(email)")
    }

    /// Website formatado
    var websiteURL: URL? {
        guard let website = website else { return nil }
        return URL(string: website)
    }

    /// Rating formatado
    var ratingFormatted: String? {
        guard let rating = rating else { return nil }
        return String(format: "%.1f", rating)
    }

    /// Stars para exibir rating
    var ratingStars: String {
        guard let rating = rating else { return "" }
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5

        var stars = String(repeating: "★", count: fullStars)
        if hasHalfStar {
            stars += "½"
        }
        let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)
        stars += String(repeating: "☆", count: emptyStars)

        return stars
    }

    /// Horário de funcionamento formatado
    var openingHoursFormatted: String? {
        openingHours
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - POI Type

/// Tipos de pontos de interesse
enum POIType: String, Codable, CaseIterable, Identifiable {
    case hospital = "hospital"
    case restaurant = "restaurant"
    case hotel = "hotel"
    case attraction = "attraction"
    case transport = "transport"
    case shopping = "shopping"
    case government = "government"
    case education = "education"
    case culture = "culture"
    case other = "other"

    var id: String { rawValue }

    /// Descrição legível
    var description: String {
        switch self {
        case .hospital:
            return "Saúde"
        case .restaurant:
            return "Restaurantes"
        case .hotel:
            return "Hotéis"
        case .attraction:
            return "Atrações"
        case .transport:
            return "Transporte"
        case .shopping:
            return "Comércio"
        case .government:
            return "Governo"
        case .education:
            return "Educação"
        case .culture:
            return "Cultura"
        case .other:
            return "Outros"
        }
    }

    /// Ícone SF Symbol
    var iconName: String {
        switch self {
        case .hospital:
            return "cross.case.fill"
        case .restaurant:
            return "fork.knife"
        case .hotel:
            return "bed.double.fill"
        case .attraction:
            return "star.fill"
        case .transport:
            return "bus.fill"
        case .shopping:
            return "bag.fill"
        case .government:
            return "building.columns.fill"
        case .education:
            return "book.fill"
        case .culture:
            return "theatermasks.fill"
        case .other:
            return "mappin.circle.fill"
        }
    }

    /// Cor da categoria
    var colorName: String {
        switch self {
        case .hospital:
            return "AlertColor"
        case .restaurant:
            return "WarningColor"
        case .hotel:
            return "PrimaryColor"
        case .attraction:
            return "SecondaryColor"
        case .transport:
            return "PrimaryColor"
        case .shopping:
            return "SecondaryColor"
        case .government:
            return "PrimaryColor"
        case .education:
            return "PrimaryColor"
        case .culture:
            return "SecondaryColor"
        case .other:
            return "SecondaryColor"
        }
    }

    /// Emoji representativo (como no totem TOMI)
    var emoji: String {
        switch self {
        case .hospital:
            return "🏥"
        case .restaurant:
            return "🍴"
        case .hotel:
            return "🏨"
        case .attraction:
            return "🎭"
        case .transport:
            return "🚌"
        case .shopping:
            return "🛍️"
        case .government:
            return "🏛️"
        case .education:
            return "📚"
        case .culture:
            return "🎨"
        case .other:
            return "📍"
        }
    }
}
