//
//  CameraDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de câmeras
//

import Foundation
import CoreLocation

/*
 Exemplo de resposta da API:
 {
   "success": true,
   "data": [
     {
       "id": "cam-001",
       "name": "Avenida Paulista - Consolação",
       "region": "Centro",
       "status": "online",
       "latitude": -23.5617,
       "longitude": -46.6562,
       "stream_url": "https://stream.example.com/cam-001",
       "thumbnail_url": "https://cdn.example.com/cam-001.jpg",
       "last_update": "2025-01-18T14:30:00Z"
     }
   ],
   "timestamp": "2025-01-18T14:30:00Z"
 }
*/

// MARK: - Cameras Response DTO

struct CamerasResponseDTO: Codable {
    let success: Bool
    let data: [CameraDataDTO]
    let timestamp: String
}

// MARK: - Camera Data DTO

struct CameraDataDTO: Codable {
    let id: String
    let name: String
    let region: String
    let status: String
    let latitude: Double
    let longitude: Double
    let streamURL: String?
    let thumbnailURL: String?
    let lastUpdate: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case region
        case status
        case latitude
        case longitude
        case streamURL = "stream_url"
        case thumbnailURL = "thumbnail_url"
        case lastUpdate = "last_update"
    }
}

// MARK: - DTO to Domain Mapping

extension CameraDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> Camera? {
        guard let cameraStatus = CameraStatus(rawValue: status) else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let updateDate = dateFormatter.date(from: lastUpdate) else {
            return nil
        }

        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        return Camera(
            id: id,
            name: name,
            region: region,
            status: cameraStatus,
            coordinate: coordinate,
            streamURL: streamURL,
            thumbnailURL: thumbnailURL,
            lastUpdate: updateDate
        )
    }
}

extension Array where Element == CameraDataDTO {

    /// Converte array de DTOs para modelos de domínio
    func toDomain() -> [Camera] {
        compactMap { $0.toDomain() }
    }
}
