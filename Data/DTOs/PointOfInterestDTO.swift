//
//  PointOfInterestDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de POIs
//

import Foundation
import CoreLocation

/*
 Exemplo de resposta da API Django:
 GET /api/v1/pois/?city=CITY_ID&type=restaurant

 {
   "count": 25,
   "next": null,
   "previous": null,
   "results": [
     {
       "id": "poi-001",
       "name": "Hospital Central",
       "description": "Hospital público com atendimento 24h",
       "type": "hospital",
       "address": "Rua das Flores, 123 - Centro",
       "latitude": -23.5505,
       "longitude": -46.6333,
       "phone": "(11) 1234-5678",
       "email": "contato@hospital.com.br",
       "website": "https://hospital.com.br",
       "image": "https://cdn.example.com/pois/hospital001.jpg",
       "opening_hours": "24 horas",
       "rating": 4.5,
       "city": "cidade-001"
     }
   ]
 }
*/

// MARK: - POIs Response DTO

struct POIsResponseDTO: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [POIDataDTO]
}

// MARK: - POI Data DTO

struct POIDataDTO: Codable {
    let id: String
    let name: String
    let description: String?
    let type: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phone: String?
    let email: String?
    let website: String?
    let image: String?
    let openingHours: String?
    let rating: Double?
    let city: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case address
        case latitude
        case longitude
        case phone
        case email
        case website
        case image
        case openingHours = "opening_hours"
        case rating
        case city
    }
}

// MARK: - DTO to Domain Mapping

extension POIDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> PointOfInterest? {
        guard let poiType = POIType(rawValue: type) else {
            return nil
        }

        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        return PointOfInterest(
            id: id,
            name: name,
            description: description,
            type: poiType,
            address: address,
            coordinate: coordinate,
            phone: phone,
            email: email,
            website: website,
            imageURL: image,
            openingHours: openingHours,
            rating: rating,
            city: city
        )
    }
}

extension Array where Element == POIDataDTO {

    /// Converte array de DTOs para modelos de domínio
    func toDomain() -> [PointOfInterest] {
        compactMap { $0.toDomain() }
    }
}
