import Foundation

enum MockData {
    static let weather = Weather(
        id: UUID(),
        temperature: 28.5,
        condition: .partlyCloudy,
        humidity: 75,
        windSpeed: 12.5,
        location: "Niterói, RJ",
        updatedAt: Date()
    )

    static let cameras: [Camera] = [
        Camera(
            id: UUID(),
            name: "Centro - Praça Arariboia",
            location: Location(latitude: -22.8939, longitude: -43.1245, address: "Praça Arariboia", neighborhood: "Centro", city: "Niterói"),
            streamURL: URL(string: "https://example.com/stream1"),
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "Icaraí - Praia",
            location: Location(latitude: -22.9042, longitude: -43.1087, address: "Av. Moreira César", neighborhood: "Icaraí", city: "Niterói"),
            streamURL: URL(string: "https://example.com/stream2"),
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "São Francisco - Orla",
            location: Location(latitude: -22.9156, longitude: -43.0934, address: "Av. Quintino Bocaiúva", neighborhood: "São Francisco", city: "Niterói"),
            streamURL: URL(string: "https://example.com/stream3"),
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "Charitas - Praia",
            location: Location(latitude: -22.9367, longitude: -43.0645, address: "Praia de Charitas", neighborhood: "Charitas", city: "Niterói"),
            streamURL: nil,
            thumbnailURL: nil,
            isOnline: false,
            lastUpdate: Date().addingTimeInterval(-3600)
        ),
        Camera(
            id: UUID(),
            name: "Ingá - Campo de São Bento",
            location: Location(latitude: -22.9003, longitude: -43.1156, address: "Campo de São Bento", neighborhood: "Ingá", city: "Niterói"),
            streamURL: URL(string: "https://example.com/stream5"),
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "Centro - Terminal Rodoviário",
            location: Location(latitude: -22.8912, longitude: -43.1278, address: "Terminal Rodoviário", neighborhood: "Centro", city: "Niterói"),
            streamURL: nil,
            thumbnailURL: nil,
            isOnline: false,
            lastUpdate: Date().addingTimeInterval(-7200)
        )
    ]

    static let alerts: [Alert] = [
        Alert(
            id: UUID(),
            title: "Alagamento na Av. Amaral Peixoto",
            description: "Devido às fortes chuvas, há pontos de alagamento na Av. Amaral Peixoto no Centro. Evite a região.",
            severity: .high,
            category: .weather,
            location: Location(latitude: -22.8950, longitude: -43.1230, address: "Av. Amaral Peixoto", neighborhood: "Centro", city: "Niterói"),
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(7200)
        ),
        Alert(
            id: UUID(),
            title: "Obras na Ponte Rio-Niterói",
            description: "Obras de manutenção na Ponte Rio-Niterói. Trânsito lento no sentido Rio de Janeiro.",
            severity: .medium,
            category: .traffic,
            location: Location(latitude: -22.8750, longitude: -43.1500, address: "Ponte Rio-Niterói", neighborhood: "Centro", city: "Niterói"),
            createdAt: Date().addingTimeInterval(-3600),
            expiresAt: nil
        ),
        Alert(
            id: UUID(),
            title: "Campanha de Vacinação",
            description: "Campanha de vacinação contra gripe nos postos de saúde de Niterói até sexta-feira.",
            severity: .low,
            category: .health,
            location: nil,
            createdAt: Date().addingTimeInterval(-86400),
            expiresAt: Date().addingTimeInterval(432000)
        )
    ]

    // Eventos baseados no design - Carnaval, Festa Junina, etc.
    static let events: [Event] = [
        Event(
            id: UUID(),
            title: "Carnaval de Niterói 2026",
            description: "Desfiles de escolas de samba, blocos de rua e matinês para crianças. Programação completa em diversos bairros da cidade.",
            category: .cultural,
            location: Location(latitude: -22.8833, longitude: -43.1036, address: "Centro de Niterói"),
            startDate: createDate(day: 14, month: 2, year: 2026),
            endDate: createDate(day: 18, month: 2, year: 2026),
            imageURL: nil,
            organizer: "Prefeitura de Niterói",
            isFree: true,
            price: nil
        ),
        Event(
            id: UUID(),
            title: "Festa Junina no Horto do Fonseca",
            description: "Tradicional festa junina com quadrilhas, comidas típicas, fogueira e forró. Diversão para toda a família.",
            category: .cultural,
            location: Location(latitude: -22.8900, longitude: -43.1200, address: "Horto do Fonseca"),
            startDate: createDate(day: 20, month: 6, year: 2026),
            endDate: createDate(day: 20, month: 6, year: 2026),
            imageURL: nil,
            organizer: "Secretaria de Cultura",
            isFree: true,
            price: nil
        ),
        Event(
            id: UUID(),
            title: "Festa de São Pedro dos Pescadores",
            description: "Celebração tradicional em homenagem a São Pedro, padroeiro dos pescadores, com procissão marítima e shows.",
            category: .cultural,
            location: Location(latitude: -22.8800, longitude: -43.1100, address: "Praia de Jurujuba"),
            startDate: createDate(day: 29, month: 6, year: 2026),
            endDate: nil,
            imageURL: nil,
            organizer: "Colônia de Pescadores",
            isFree: true,
            price: nil
        ),
        Event(
            id: UUID(),
            title: "Grande Exposição de Fuscas",
            description: "Encontro de colecionadores e entusiastas do Fusca com exposição de veículos restaurados.",
            category: .cultural,
            location: Location(latitude: -22.8950, longitude: -43.1050, address: "Campo de São Bento"),
            startDate: createDate(day: 15, month: 12, year: 2026),
            endDate: nil,
            imageURL: nil,
            organizer: "Clube do Fusca Niterói",
            isFree: true,
            price: nil
        ),
        Event(
            id: UUID(),
            title: "Feira Orgânica de Icaraí",
            description: "Feira semanal com produtos orgânicos, artesanato local e apresentações musicais.",
            category: .community,
            location: Location(latitude: -22.9000, longitude: -43.1100, address: "Praça de Icaraí"),
            startDate: createDate(day: 21, month: 12, year: 2026),
            endDate: nil,
            imageURL: nil,
            organizer: "Associação de Produtores",
            isFree: true,
            price: nil
        ),
        Event(
            id: UUID(),
            title: "Exposição: Arte Contemporânea Brasileira",
            description: "Mostra de arte contemporânea com obras de artistas brasileiros renomados no MAC Niterói.",
            category: .cultural,
            location: Location(latitude: -22.9064, longitude: -43.1250, address: "MAC Niterói"),
            startDate: createDate(day: 22, month: 12, year: 2026),
            endDate: createDate(day: 22, month: 3, year: 2027),
            imageURL: nil,
            organizer: "MAC Niterói",
            isFree: false,
            price: 20.0
        )
    ]

    static let news: [News] = [
        News(
            id: UUID(),
            title: "Nova ciclovia conecta Icaraí ao Centro de Niterói",
            summary: "A partir de segunda-feira, nova ciclovia entra em operação ligando os dois bairros.",
            content: "A Prefeitura de Niterói anunciou a inauguração de uma nova ciclovia que conectará o bairro de Icaraí ao Centro da cidade, passando pelo Campo de São Bento.",
            category: .infrastructure,
            imageURL: nil,
            source: "Portal da Prefeitura de Niterói",
            publishedAt: Date(),
            url: nil
        ),
        News(
            id: UUID(),
            title: "UPA do Fonseca amplia horário de atendimento",
            summary: "Unidade de Pronto Atendimento passa a funcionar 24 horas.",
            content: "A UPA do Fonseca em Niterói agora funciona 24 horas por dia para melhor atender a população.",
            category: .health,
            imageURL: nil,
            source: "Secretaria de Saúde de Niterói",
            publishedAt: Date().addingTimeInterval(-86400),
            url: nil
        )
    ]

    static let pointsOfInterest: [PointOfInterest] = [
        PointOfInterest(
            id: UUID(),
            name: "Hospital Universitário Antônio Pedro",
            description: "Hospital universitário de referência em Niterói.",
            category: .hospital,
            location: Location(latitude: -22.8980, longitude: -43.1200, address: "Av. Marquês do Paraná", neighborhood: "Centro", city: "Niterói"),
            imageURL: nil,
            phone: "(21) 2629-9000",
            website: nil,
            openingHours: "24 horas",
            rating: 4.2
        ),
        PointOfInterest(
            id: UUID(),
            name: "MAC Niterói",
            description: "Museu de Arte Contemporânea, ícone arquitetônico de Oscar Niemeyer.",
            category: .museum,
            location: Location(latitude: -22.9064, longitude: -43.1250, address: "Mirante da Boa Viagem", neighborhood: "Boa Viagem", city: "Niterói"),
            imageURL: nil,
            phone: "(21) 2620-2400",
            website: nil,
            openingHours: "10:00 - 18:00",
            rating: 4.8
        ),
        PointOfInterest(
            id: UUID(),
            name: "Fortaleza de Santa Cruz",
            description: "Fortaleza histórica na entrada da Baía de Guanabara.",
            category: .tourism,
            location: Location(latitude: -22.9340, longitude: -43.0140, address: "Estrada General Eurico Gaspar Dutra", neighborhood: "Jurujuba", city: "Niterói"),
            imageURL: nil,
            phone: "(21) 2710-7840",
            website: nil,
            openingHours: "09:00 - 17:00",
            rating: 4.7
        )
    ]

    // Helper para criar datas
    private static func createDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = 10
        return Calendar.current.date(from: components) ?? Date()
    }
}
