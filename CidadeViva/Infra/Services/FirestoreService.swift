import Foundation
import FirebaseFirestore

/// Serviço para comunicação com o Firestore
final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Coleções

    private enum Collection: String {
        case alertas
        case eventos
        case cameras
        case noticias
        case banners
    }

    // MARK: - Fetch Alertas

    func fetchAlerts() async throws -> [Alert] {
        let snapshot = try await db.collection(Collection.alertas.rawValue)
            .whereField("ativo", isEqualTo: true)
            .order(by: "criadoEm", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            Self.mapDocumentToAlert(document)
        }
    }

    // MARK: - Fetch Eventos

    func fetchEvents() async throws -> [Event] {
        let snapshot = try await db.collection(Collection.eventos.rawValue)
            .order(by: "dataInicio", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            Self.mapDocumentToEvent(document)
        }
    }

    // MARK: - Fetch Câmeras

    func fetchCameras() async throws -> [Camera] {
        let snapshot = try await db.collection(Collection.cameras.rawValue)
            .order(by: "nome")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            Self.mapDocumentToCamera(document)
        }
    }

    // MARK: - Fetch Banners

    func fetchBanners() async throws -> [Banner] {
        // Busca todos os banners e filtra/ordena localmente para evitar necessidade de índice composto
        let snapshot = try await db.collection(Collection.banners.rawValue)
            .getDocuments()

        return snapshot.documents
            .compactMap { document in
                Self.mapDocumentToBanner(document)
            }
            .filter { $0.isActive }
            .sorted { $0.order < $1.order }
    }

    // MARK: - Fetch Notícias

    func fetchNews() async throws -> [News] {
        let snapshot = try await db.collection(Collection.noticias.rawValue)
            .whereField("ativo", isEqualTo: true)
            .order(by: "publicadoEm", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            Self.mapDocumentToNews(document)
        }
    }

    // MARK: - Mapeamento Firestore → Domain Models

    private static func mapDocumentToAlert(_ document: DocumentSnapshot) -> Alert? {
        guard let data = document.data() else { return nil }

        let titulo = data["titulo"] as? String ?? ""
        let descricao = data["descricao"] as? String ?? ""
        let tipoRaw = data["tipo"] as? String ?? "infrastructure"
        let severidadeRaw = data["severidade"] as? String ?? "low"
        let localizacao = data["localizacao"] as? String ?? ""
        let criadoEm = (data["criadoEm"] as? Timestamp)?.dateValue() ?? Date()
        let expiraEm = (data["expiraEm"] as? Timestamp)?.dateValue()

        // Mapear coordenadas
        var location: Location? = nil
        if let coords = data["coordenadas"] as? [String: Any],
           let lat = coords["latitude"] as? Double,
           let lon = coords["longitude"] as? Double {
            location = Location(
                latitude: lat,
                longitude: lon,
                address: localizacao,
                city: "João Pessoa"
            )
        } else if !localizacao.isEmpty {
            // Se não tem coordenadas, cria location apenas com endereço
            location = Location(
                latitude: -7.1195,
                longitude: -34.8450,
                address: localizacao,
                city: "João Pessoa"
            )
        }

        // Mapear severidade
        let severity: Alert.Severity
        switch severidadeRaw {
        case "low": severity = .low
        case "medium": severity = .medium
        case "high": severity = .high
        case "critical": severity = .critical
        default: severity = .low
        }

        // Mapear categoria/tipo
        let category: Alert.Category
        switch tipoRaw {
        case "traffic": category = .traffic
        case "weather": category = .weather
        case "security": category = .security
        case "health": category = .health
        case "infrastructure": category = .infrastructure
        case "event": category = .event
        default: category = .infrastructure
        }

        return Alert(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: titulo,
            description: descricao,
            severity: severity,
            category: category,
            location: location,
            createdAt: criadoEm,
            expiresAt: expiraEm
        )
    }

    private static func mapDocumentToEvent(_ document: DocumentSnapshot) -> Event? {
        guard let data = document.data() else { return nil }

        let titulo = data["titulo"] as? String ?? ""
        let descricao = data["descricao"] as? String ?? ""
        let categoriaRaw = data["categoria"] as? String ?? "cultural"
        let local = data["local"] as? String ?? ""
        let dataInicio = (data["dataInicio"] as? Timestamp)?.dateValue() ?? Date()
        let dataFim = (data["dataFim"] as? Timestamp)?.dateValue()
        let imagemURL = data["imagemURL"] as? String
        let organizador = data["organizador"] as? String
        let gratuito = data["gratuito"] as? Bool ?? true
        let preco = data["preco"] as? Double

        // Mapear coordenadas
        var latitude = -7.1195
        var longitude = -34.8450
        if let coords = data["coordenadas"] as? [String: Any] {
            latitude = coords["latitude"] as? Double ?? latitude
            longitude = coords["longitude"] as? Double ?? longitude
        }

        let location = Location(
            latitude: latitude,
            longitude: longitude,
            address: local,
            city: "João Pessoa"
        )

        // Mapear categoria
        let category: Event.Category
        switch categoriaRaw {
        case "cultural": category = .cultural
        case "esportivo", "sports": category = .sports
        case "educacional", "education": category = .education
        case "comunitario", "community": category = .community
        case "religioso": category = .community
        case "saude", "health": category = .health
        case "governo", "government": category = .government
        case "musica", "music": category = .music
        default: category = .cultural
        }

        var imageURL: URL? = nil
        if let urlString = imagemURL, !urlString.isEmpty {
            imageURL = URL(string: urlString)
        }

        return Event(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: titulo,
            description: descricao,
            category: category,
            location: location,
            startDate: dataInicio,
            endDate: dataFim,
            imageURL: imageURL,
            organizer: organizador,
            isFree: gratuito,
            price: preco
        )
    }

    private static func mapDocumentToCamera(_ document: DocumentSnapshot) -> Camera? {
        guard let data = document.data() else { return nil }

        let nome = data["nome"] as? String ?? ""
        let regiao = data["regiao"] as? String ?? ""
        let statusRaw = data["status"] as? String ?? "offline"
        let streamURLString = data["streamURL"] as? String
        let thumbnailURLString = data["thumbnailURL"] as? String
        let atualizadoEm = (data["atualizadoEm"] as? Timestamp)?.dateValue() ?? Date()

        // Mapear coordenadas
        var latitude = -7.1195
        var longitude = -34.8450
        if let coords = data["coordenadas"] as? [String: Any] {
            latitude = coords["latitude"] as? Double ?? latitude
            longitude = coords["longitude"] as? Double ?? longitude
        }

        let location = Location(
            latitude: latitude,
            longitude: longitude,
            neighborhood: regiao,
            city: "João Pessoa"
        )

        // Mapear status
        let isOnline = statusRaw == "online"

        var streamURL: URL? = nil
        if let urlString = streamURLString, !urlString.isEmpty {
            streamURL = URL(string: urlString)
        }

        var thumbnailURL: URL? = nil
        if let urlString = thumbnailURLString, !urlString.isEmpty {
            thumbnailURL = URL(string: urlString)
        }

        return Camera(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            name: nome,
            location: location,
            streamURL: streamURL,
            thumbnailURL: thumbnailURL,
            isOnline: isOnline,
            lastUpdate: atualizadoEm
        )
    }

    private static func mapDocumentToNews(_ document: DocumentSnapshot) -> News? {
        guard let data = document.data() else { return nil }

        let titulo = data["titulo"] as? String ?? ""
        let resumo = data["resumo"] as? String ?? ""
        let conteudo = data["conteudo"] as? String ?? ""
        let categoriaRaw = data["categoria"] as? String ?? "geral"
        let imagemURLString = data["imagemURL"] as? String
        let fonte = data["fonte"] as? String ?? ""
        let publicadoEm = (data["publicadoEm"] as? Timestamp)?.dateValue() ?? Date()

        // Mapear categoria
        let category: News.Category
        switch categoriaRaw {
        case "geral": category = .general
        case "politica": category = .politics
        case "economia": category = .economy
        case "saude": category = .health
        case "educacao": category = .education
        case "esportes": category = .sports
        case "cultura": category = .culture
        case "infraestrutura": category = .infrastructure
        default: category = .general
        }

        var imageURL: URL? = nil
        if let urlString = imagemURLString, !urlString.isEmpty {
            imageURL = URL(string: urlString)
        }

        return News(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: titulo,
            summary: resumo,
            content: conteudo,
            category: category,
            imageURL: imageURL,
            source: fonte,
            publishedAt: publicadoEm,
            url: nil
        )
    }

    private static func mapDocumentToBanner(_ document: DocumentSnapshot) -> Banner? {
        guard let data = document.data() else { return nil }

        let titulo = data["titulo"] as? String ?? ""
        let subtitulo = data["subtitulo"] as? String ?? ""
        let imagemURLString = data["imagemURL"] as? String
        let linkURLString = data["linkURL"] as? String
        let ordem = data["ordem"] as? Int ?? 0
        let ativo = data["ativo"] as? Bool ?? true

        var imageURL: URL? = nil
        if let urlString = imagemURLString, !urlString.isEmpty {
            imageURL = URL(string: urlString)
        }

        var linkURL: URL? = nil
        if let urlString = linkURLString, !urlString.isEmpty {
            linkURL = URL(string: urlString)
        }

        return Banner(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: titulo,
            subtitle: subtitulo,
            imageURL: imageURL,
            linkURL: linkURL,
            order: ordem,
            isActive: ativo
        )
    }
}
