//
//  Event.swift
//  CidadeViva
//
//  Modelo de domínio para eventos da cidade
//

import Foundation
import CoreLocation

/// Representa um evento da cidade
struct Event: Identifiable, Hashable {

    // MARK: - Properties

    let id: String
    let title: String
    let description: String
    let category: EventCategory
    let location: String
    let coordinate: CLLocationCoordinate2D?
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let imageURL: String?
    let isFeatured: Bool
    let organizer: String?
    let contactEmail: String?
    let contactPhone: String?
    let ticketURL: String?
    let price: Double?
    let city: String

    // MARK: - Computed Properties

    /// Data de início formatada
    var startDateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = isAllDay ? "dd 'de' MMMM" : "dd/MM 'às' HH:mm"
        return formatter.string(from: startDate)
    }

    /// Data de término formatada
    var endDateFormatted: String? {
        guard let endDate = endDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = isAllDay ? "dd 'de' MMMM" : "dd/MM 'às' HH:mm"
        return formatter.string(from: endDate)
    }

    /// Período do evento formatado
    var periodFormatted: String {
        if isAllDay {
            if let endDate = endDate {
                return "\(startDateFormatted) até \(endDateFormatted ?? "")"
            }
            return startDateFormatted
        } else {
            if let endDate = endDate, Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                let endFormatter = DateFormatter()
                endFormatter.locale = Locale(identifier: "pt_BR")
                endFormatter.dateFormat = "HH:mm"
                return "\(startDateFormatted) - \(endFormatter.string(from: endDate))"
            }
            return startDateFormatted
        }
    }

    /// Preço formatado
    var priceFormatted: String {
        if let price = price {
            if price == 0 {
                return "Grátis"
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: NSNumber(value: price)) ?? "R$ \(price)"
        }
        return "Grátis"
    }

    /// Indica se o evento já passou
    var isPast: Bool {
        if let endDate = endDate {
            return Date() > endDate
        }
        return Date() > startDate
    }

    /// Indica se o evento está acontecendo agora
    var isHappeningNow: Bool {
        let now = Date()
        if let endDate = endDate {
            return now >= startDate && now <= endDate
        }
        return Calendar.current.isDateInToday(startDate)
    }

    /// Indica se o evento é hoje
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Event Category

/// Categorias de eventos
enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case culture = "culture"
    case sports = "sports"
    case entertainment = "entertainment"
    case education = "education"
    case health = "health"
    case business = "business"
    case community = "community"
    case other = "other"

    var id: String { rawValue }

    /// Descrição legível
    var description: String {
        switch self {
        case .culture:
            return "Cultura"
        case .sports:
            return "Esportes"
        case .entertainment:
            return "Entretenimento"
        case .education:
            return "Educação"
        case .health:
            return "Saúde"
        case .business:
            return "Negócios"
        case .community:
            return "Comunidade"
        case .other:
            return "Outros"
        }
    }

    /// Ícone SF Symbol
    var iconName: String {
        switch self {
        case .culture:
            return "theatermasks.fill"
        case .sports:
            return "figure.run"
        case .entertainment:
            return "music.note"
        case .education:
            return "book.fill"
        case .health:
            return "heart.fill"
        case .business:
            return "briefcase.fill"
        case .community:
            return "person.3.fill"
        case .other:
            return "star.fill"
        }
    }

    /// Cor da categoria
    var colorName: String {
        switch self {
        case .culture:
            return "PrimaryColor"
        case .sports:
            return "SecondaryColor"
        case .entertainment:
            return "WarningColor"
        case .education:
            return "PrimaryColor"
        case .health:
            return "AlertColor"
        case .business:
            return "SecondaryColor"
        case .community:
            return "PrimaryColor"
        case .other:
            return "SecondaryColor"
        }
    }
}
