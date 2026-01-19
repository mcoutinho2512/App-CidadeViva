//
//  RouteDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de rotas
//

import Foundation
import CoreLocation

/*
 Exemplo de resposta da API Django:
 POST /api/v1/navigation/route/

 Request Body:
 {
   "origin": {"lat": -23.5505, "lng": -46.6333},
   "destination": {"lat": -23.5617, "lng": -46.6562},
   "mode": "walking"
 }

 Response:
 {
   "route_id": "route-001",
   "origin": {
     "name": "Localização Atual",
     "address": "Rua Exemplo, 123",
     "latitude": -23.5505,
     "longitude": -46.6333
   },
   "destination": {
     "name": "Avenida Paulista",
     "address": "Av. Paulista, 1000",
     "latitude": -23.5617,
     "longitude": -46.6562
   },
   "mode": "walking",
   "distance": 1500.5,
   "duration": 1200.0,
   "coordinates": [
     [-46.6333, -23.5505],
     [-46.6340, -23.5510],
     ...
   ],
   "instructions": [
     {
       "id": "inst-001",
       "text": "Siga em frente pela Rua Exemplo",
       "distance": 500.0,
       "duration": 360.0,
       "latitude": -23.5505,
       "longitude": -46.6333,
       "type": "straight"
     }
   ],
   "created_at": "2026-01-18T14:30:00Z"
 }
*/

// MARK: - Route Response DTO

struct RouteResponseDTO: Codable {
    let routeId: String
    let origin: RoutePointDTO
    let destination: RoutePointDTO
    let mode: String
    let distance: Double
    let duration: Double
    let coordinates: [[Double]]
    let instructions: [RouteInstructionDTO]?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
        case origin
        case destination
        case mode
        case distance
        case duration
        case coordinates
        case instructions
        case createdAt = "created_at"
    }
}

// MARK: - Route Point DTO

struct RoutePointDTO: Codable {
    let name: String
    let address: String?
    let latitude: Double
    let longitude: Double
}

// MARK: - Route Instruction DTO

struct RouteInstructionDTO: Codable {
    let id: String
    let text: String
    let distance: Double
    let duration: Double
    let latitude: Double
    let longitude: Double
    let type: String
}

// MARK: - DTO to Domain Mapping

extension RouteResponseDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> Route? {
        guard let routeMode = RouteMode(rawValue: mode) else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let createdDate = dateFormatter.date(from: createdAt) else {
            return nil
        }

        // Converte coordenadas [[lng, lat]] para [CLLocationCoordinate2D]
        let coords = coordinates.compactMap { coord -> CLLocationCoordinate2D? in
            guard coord.count == 2 else { return nil }
            // OpenRouteService retorna [longitude, latitude]
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }

        let originPoint = RoutePoint(
            name: origin.name,
            address: origin.address,
            coordinate: CLLocationCoordinate2D(
                latitude: origin.latitude,
                longitude: origin.longitude
            )
        )

        let destinationPoint = RoutePoint(
            name: destination.name,
            address: destination.address,
            coordinate: CLLocationCoordinate2D(
                latitude: destination.latitude,
                longitude: destination.longitude
            )
        )

        let routeInstructions = instructions?.compactMap { $0.toDomain() }

        return Route(
            id: routeId,
            origin: originPoint,
            destination: destinationPoint,
            mode: routeMode,
            distance: distance,
            duration: duration,
            coordinates: coords,
            instructions: routeInstructions,
            createdAt: createdDate
        )
    }
}

extension RouteInstructionDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> RouteInstruction? {
        guard let instructionType = InstructionType(rawValue: type) else {
            return nil
        }

        return RouteInstruction(
            id: id,
            text: text,
            distance: distance,
            duration: duration,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            type: instructionType
        )
    }
}
