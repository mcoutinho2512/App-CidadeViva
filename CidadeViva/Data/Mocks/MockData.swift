import Foundation

enum MockData {
    static let weather = Weather(
        id: UUID(),
        temperature: 28.5,
        condition: .partlyCloudy,
        humidity: 75,
        windSpeed: 12.5,
        location: "João Pessoa, PB",
        updatedAt: Date()
    )

    static let cameras: [Camera] = [
        Camera(
            id: UUID(),
            name: "Av. Epitácio Pessoa - Tambaú",
            location: Location(latitude: -7.1153, longitude: -34.8450, address: "Av. Epitácio Pessoa, Tambaú"),
            streamURL: nil,
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "Orla de Cabo Branco",
            location: Location(latitude: -7.1478, longitude: -34.8243, address: "Av. Cabo Branco"),
            streamURL: nil,
            thumbnailURL: nil,
            isOnline: true,
            lastUpdate: Date()
        ),
        Camera(
            id: UUID(),
            name: "Centro - Lagoa",
            location: Location(latitude: -7.1195, longitude: -34.8761, address: "Parque Solon de Lucena"),
            streamURL: nil,
            thumbnailURL: nil,
            isOnline: false,
            lastUpdate: Date().addingTimeInterval(-3600)
        )
    ]

    static let alerts: [Alert] = [
        Alert(
            id: UUID(),
            title: "Alagamento na Av. Cruz das Armas",
            description: "Devido às fortes chuvas, há pontos de alagamento na Av. Cruz das Armas. Evite a região.",
            severity: .high,
            category: .weather,
            location: Location(latitude: -7.1350, longitude: -34.8890, address: "Av. Cruz das Armas"),
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(7200)
        ),
        Alert(
            id: UUID(),
            title: "Obras na BR-230",
            description: "Obras de recapeamento na BR-230. Trânsito lento no sentido Centro-Cabedelo.",
            severity: .medium,
            category: .traffic,
            location: Location(latitude: -7.0833, longitude: -34.8500, address: "BR-230"),
            createdAt: Date().addingTimeInterval(-3600),
            expiresAt: nil
        ),
        Alert(
            id: UUID(),
            title: "Campanha de Vacinação",
            description: "Campanha de vacinação contra gripe nos postos de saúde até sexta-feira.",
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
            title: "Nova linha de ônibus conecta Mangabeira ao Centro",
            summary: "A partir de segunda-feira, nova linha de transporte coletivo entra em operação.",
            content: "A Prefeitura de João Pessoa anunciou a criação de uma nova linha de ônibus que conectará o bairro de Mangabeira ao Centro da cidade.",
            category: .infrastructure,
            imageURL: nil,
            source: "Portal da Prefeitura",
            publishedAt: Date(),
            url: nil
        ),
        News(
            id: UUID(),
            title: "UPA de Mangabeira amplia horário de atendimento",
            summary: "Unidade de Pronto Atendimento passa a funcionar 24 horas.",
            content: "A UPA de Mangabeira agora funciona 24 horas por dia para melhor atender a população.",
            category: .health,
            imageURL: nil,
            source: "Secretaria de Saúde",
            publishedAt: Date().addingTimeInterval(-86400),
            url: nil
        )
    ]

    static let pointsOfInterest: [PointOfInterest] = [
        PointOfInterest(
            id: UUID(),
            name: "Hospital de Trauma",
            description: "Hospital de emergência e trauma da cidade.",
            category: .hospital,
            location: Location(latitude: -7.1089, longitude: -34.8631, address: "Av. Orestes Lisboa"),
            imageURL: nil,
            phone: "(83) 3216-6000",
            website: nil,
            openingHours: "24 horas",
            rating: 4.2
        ),
        PointOfInterest(
            id: UUID(),
            name: "Farol do Cabo Branco",
            description: "Ponto mais oriental das Américas com vista panorâmica.",
            category: .tourism,
            location: Location(latitude: -7.1486, longitude: -34.7976, address: "Cabo Branco"),
            imageURL: nil,
            phone: nil,
            website: nil,
            openingHours: "08:00 - 17:00",
            rating: 4.8
        ),
        PointOfInterest(
            id: UUID(),
            name: "Estação Ciência",
            description: "Centro de ciência e planetário.",
            category: .museum,
            location: Location(latitude: -7.1153, longitude: -34.8634, address: "Parque Solon de Lucena"),
            imageURL: nil,
            phone: "(83) 3214-8300",
            website: nil,
            openingHours: "09:00 - 17:00",
            rating: 4.5
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
