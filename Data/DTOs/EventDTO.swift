//
//  EventDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de eventos
//

import Foundation
import CoreLocation

/*
 Exemplo de resposta da API Django (baseado no seu totem):
 GET /api/v1/events/?city=CITY_ID

 {
   "count": 10,
   "next": null,
   "previous": null,
   "results": [
     {
       "id": "evt-001",
       "title": "Festival de Música",
       "description": "Festival anual com bandas locais...",
       "category": "culture",
       "location_name": "Praça Central",
       "latitude": -23.5505,
       "longitude": -46.6333,
       "start_date": "2026-02-01T19:00:00Z",
       "end_date": "2026-02-01T23:00:00Z",
       "all_day": false,
       "image": "https://cdn.example.com/events/fest001.jpg",
       "is_featured": true,
       "organizer": "Prefeitura",
       "contact_email": "eventos@cidade.gov.br",
       "contact_phone": "(11) 1234-5678",
       "ticket_url": "https://ingressos.com/festival",
       "price": 0.0,
       "city": "cidade-001",
       "created_at": "2026-01-10T10:00:00Z"
     }
   ]
 }
*/

// MARK: - Events Response DTO

struct EventsResponseDTO: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [EventDataDTO]
}

// MARK: - Event Data DTO

struct EventDataDTO: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let locationName: String
    let latitude: Double?
    let longitude: Double?
    let startDate: String
    let endDate: String?
    let allDay: Bool
    let image: String?
    let isFeatured: Bool
    let organizer: String?
    let contactEmail: String?
    let contactPhone: String?
    let ticketURL: String?
    let price: Double?
    let city: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case locationName = "location_name"
        case latitude
        case longitude
        case startDate = "start_date"
        case endDate = "end_date"
        case allDay = "all_day"
        case image
        case isFeatured = "is_featured"
        case organizer
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case ticketURL = "ticket_url"
        case price
        case city
        case createdAt = "created_at"
    }
}

// MARK: - DTO to Domain Mapping

extension EventDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> Event? {
        guard let eventCategory = EventCategory(rawValue: category) else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let startDateParsed = dateFormatter.date(from: startDate) else {
            return nil
        }

        var endDateParsed: Date?
        if let endDate = endDate {
            endDateParsed = dateFormatter.date(from: endDate)
        }

        var coordinate: CLLocationCoordinate2D?
        if let lat = latitude, let lon = longitude {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return Event(
            id: id,
            title: title,
            description: description,
            category: eventCategory,
            location: locationName,
            coordinate: coordinate,
            startDate: startDateParsed,
            endDate: endDateParsed,
            isAllDay: allDay,
            imageURL: image,
            isFeatured: isFeatured,
            organizer: organizer,
            contactEmail: contactEmail,
            contactPhone: contactPhone,
            ticketURL: ticketURL,
            price: price,
            city: city
        )
    }
}

extension Array where Element == EventDataDTO {

    /// Converte array de DTOs para modelos de domínio
    func toDomain() -> [Event] {
        compactMap { $0.toDomain() }
    }
}
