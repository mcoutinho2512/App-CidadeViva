//
//  News.swift
//  CidadeViva
//
//  Modelo de domínio para notícias da cidade
//

import Foundation

/// Representa uma notícia local
struct News: Identifiable, Hashable {

    // MARK: - Properties

    let id: String
    let title: String
    let summary: String
    let content: String?
    let imageURL: String?
    let publishedAt: Date
    let expiresAt: Date?
    let isFeatured: Bool
    let category: String?
    let author: String?
    let sourceURL: String?
    let city: String

    // MARK: - Computed Properties

    /// Data de publicação formatada
    var publishedAtFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }

    /// Data de publicação absoluta
    var publishedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: publishedAt)
    }

    /// Indica se a notícia está expirada
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    /// Indica se é notícia recente (menos de 24h)
    var isRecent: Bool {
        let dayAgo = Date().addingTimeInterval(-86400)
        return publishedAt > dayAgo
    }

    /// Preview do conteúdo (primeiros 150 caracteres)
    var contentPreview: String? {
        guard let content = content else { return nil }
        if content.count <= 150 {
            return content
        }
        let index = content.index(content.startIndex, offsetBy: 150)
        return String(content[..<index]) + "..."
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: News, rhs: News) -> Bool {
        lhs.id == rhs.id
    }
}
