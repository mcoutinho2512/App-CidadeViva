//
//  NewsDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de notícias
//

import Foundation

/*
 Exemplo de resposta da API Django:
 GET /api/v1/news/?city=CITY_ID

 {
   "count": 15,
   "next": null,
   "previous": null,
   "results": [
     {
       "id": "news-001",
       "title": "Nova ciclovia inaugurada na Av. Principal",
       "summary": "Prefeitura inaugura 5km de ciclovia conectando...",
       "content": "A Prefeitura inaugurou hoje 5km de ciclovia...",
       "image": "https://cdn.example.com/news/ciclovia001.jpg",
       "published_at": "2026-01-18T08:00:00Z",
       "expires_at": "2026-02-18T08:00:00Z",
       "is_featured": true,
       "category": "Transporte",
       "author": "Assessoria de Imprensa",
       "source_url": "https://cidade.gov.br/noticias/ciclovia",
       "city": "cidade-001"
     }
   ]
 }
*/

// MARK: - News Response DTO

struct NewsResponseDTO: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [NewsDataDTO]
}

// MARK: - News Data DTO

struct NewsDataDTO: Codable {
    let id: String
    let title: String
    let summary: String
    let content: String?
    let image: String?
    let publishedAt: String
    let expiresAt: String?
    let isFeatured: Bool
    let category: String?
    let author: String?
    let sourceURL: String?
    let city: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case content
        case image
        case publishedAt = "published_at"
        case expiresAt = "expires_at"
        case isFeatured = "is_featured"
        case category
        case author
        case sourceURL = "source_url"
        case city
    }
}

// MARK: - DTO to Domain Mapping

extension NewsDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> News? {
        let dateFormatter = ISO8601DateFormatter()
        guard let publishedDate = dateFormatter.date(from: publishedAt) else {
            return nil
        }

        var expirationDate: Date?
        if let expiresAt = expiresAt {
            expirationDate = dateFormatter.date(from: expiresAt)
        }

        return News(
            id: id,
            title: title,
            summary: summary,
            content: content,
            imageURL: image,
            publishedAt: publishedDate,
            expiresAt: expirationDate,
            isFeatured: isFeatured,
            category: category,
            author: author,
            sourceURL: sourceURL,
            city: city
        )
    }
}

extension Array where Element == NewsDataDTO {

    /// Converte array de DTOs para modelos de domínio
    func toDomain() -> [News] {
        compactMap { $0.toDomain() }
    }
}
