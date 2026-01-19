//
//  AlertDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de alertas
//

import Foundation
import CoreLocation

/*
 Exemplo de resposta da API:
 {
   "success": true,
   "data": [
     {
       "id": "alert-001",
       "type": "traffic",
       "severity": "high",
       "title": "Congestionamento na Marginal Tietê",
       "description": "Trânsito lento entre Ponte das Bandeiras e Ponte Atibaia",
       "location": "Marginal Tietê, zona Norte",
       "latitude": -23.5231,
       "longitude": -46.6476,
       "created_at": "2025-01-18T14:00:00Z",
       "expires_at": "2025-01-18T18:00:00Z",
       "is_active": true
     }
   ],
   "timestamp": "2025-01-18T14:30:00Z"
 }
*/

// MARK: - Alerts Response DTO

struct AlertsResponseDTO: Codable {
    let success: Bool
    let data: [AlertDataDTO]
    let timestamp: String
}

// MARK: - Alert Data DTO

struct AlertDataDTO: Codable {
    let id: String
    let type: String
    let severity: String
    let title: String
    let description: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let expiresAt: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case severity
        case title
        case description
        case location
        case latitude
        case longitude
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case isActive = "is_active"
    }
}

// MARK: - DTO to Domain Mapping

extension AlertDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> Alert? {
        guard let alertType = AlertType(rawValue: type),
              let alertSeverity = AlertSeverity(rawValue: severity) else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let createdDate = dateFormatter.date(from: createdAt) else {
            return nil
        }

        var expirationDate: Date?
        if let expiresAt = expiresAt {
            expirationDate = dateFormatter.date(from: expiresAt)
        }

        var coordinate: CLLocationCoordinate2D?
        if let lat = latitude, let lon = longitude {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return Alert(
            id: id,
            type: alertType,
            severity: alertSeverity,
            title: title,
            description: description,
            location: location,
            coordinate: coordinate,
            createdAt: createdDate,
            expiresAt: expirationDate,
            isActive: isActive
        )
    }
}

extension Array where Element == AlertDataDTO {

    /// Converte array de DTOs para modelos de domínio
    func toDomain() -> [Alert] {
        compactMap { $0.toDomain() }
    }
}
