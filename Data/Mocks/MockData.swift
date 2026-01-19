//
//  MockData.swift
//  CidadeViva
//
//  Dados mockados para desenvolvimento e demonstração
//

import Foundation
import CoreLocation

/// Provedor de dados mockados para o aplicativo
enum MockData {

    // MARK: - Weather Mock

    static func mockWeather() -> Weather {
        Weather(
            id: "weather-001",
            temperature: 28.5,
            feelsLike: 30.2,
            condition: .partlyCloudy,
            humidity: 65,
            windSpeed: 15.3,
            lastUpdated: Date().addingTimeInterval(-300), // 5 minutos atrás
            location: "São Paulo - SP"
        )
    }

    static func mockWeatherDTO() -> WeatherResponseDTO {
        WeatherResponseDTO(
            success: true,
            data: WeatherDataDTO(
                id: "weather-001",
                temperature: 28.5,
                feelsLike: 30.2,
                condition: "partly_cloudy",
                humidity: 65,
                windSpeed: 15.3,
                location: "São Paulo - SP",
                lastUpdated: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300))
            ),
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Cameras Mock

    static func mockCameras() -> [Camera] {
        [
            Camera(
                id: "cam-001",
                name: "Avenida Paulista - Consolação",
                region: "Centro",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6562),
                streamURL: "https://stream.example.com/cam-001",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-180)
            ),
            Camera(
                id: "cam-002",
                name: "Marginal Tietê - Ponte das Bandeiras",
                region: "Norte",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -23.5231, longitude: -46.6476),
                streamURL: "https://stream.example.com/cam-002",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-120)
            ),
            Camera(
                id: "cam-003",
                name: "Avenida 23 de Maio - Paraíso",
                region: "Sul",
                status: .offline,
                coordinate: CLLocationCoordinate2D(latitude: -23.5733, longitude: -46.6417),
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-3600)
            ),
            Camera(
                id: "cam-004",
                name: "Avenida Rebouças - Pinheiros",
                region: "Oeste",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6862),
                streamURL: "https://stream.example.com/cam-004",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-60)
            ),
            Camera(
                id: "cam-005",
                name: "Radial Leste - Tatuapé",
                region: "Leste",
                status: .maintenance,
                coordinate: CLLocationCoordinate2D(latitude: -23.5422, longitude: -46.5756),
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-7200)
            ),
            Camera(
                id: "cam-006",
                name: "Avenida Ibirapuera - Moema",
                region: "Sul",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -23.5989, longitude: -46.6622),
                streamURL: "https://stream.example.com/cam-006",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-90)
            )
        ]
    }

    static func mockCamerasDTO() -> CamerasResponseDTO {
        let cameras = [
            CameraDataDTO(
                id: "cam-001",
                name: "Avenida Paulista - Consolação",
                region: "Centro",
                status: "online",
                latitude: -23.5617,
                longitude: -46.6562,
                streamURL: "https://stream.example.com/cam-001",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-180))
            ),
            CameraDataDTO(
                id: "cam-002",
                name: "Marginal Tietê - Ponte das Bandeiras",
                region: "Norte",
                status: "online",
                latitude: -23.5231,
                longitude: -46.6476,
                streamURL: "https://stream.example.com/cam-002",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-120))
            ),
            CameraDataDTO(
                id: "cam-003",
                name: "Avenida 23 de Maio - Paraíso",
                region: "Sul",
                status: "offline",
                latitude: -23.5733,
                longitude: -46.6417,
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
            ),
            CameraDataDTO(
                id: "cam-004",
                name: "Avenida Rebouças - Pinheiros",
                region: "Oeste",
                status: "online",
                latitude: -23.5617,
                longitude: -46.6862,
                streamURL: "https://stream.example.com/cam-004",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-60))
            ),
            CameraDataDTO(
                id: "cam-005",
                name: "Radial Leste - Tatuapé",
                region: "Leste",
                status: "maintenance",
                latitude: -23.5422,
                longitude: -46.5756,
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
            ),
            CameraDataDTO(
                id: "cam-006",
                name: "Avenida Ibirapuera - Moema",
                region: "Sul",
                status: "online",
                latitude: -23.5989,
                longitude: -46.6622,
                streamURL: "https://stream.example.com/cam-006",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-90))
            )
        ]

        return CamerasResponseDTO(
            success: true,
            data: cameras,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Alerts Mock

    static func mockAlerts() -> [Alert] {
        [
            Alert(
                id: "alert-001",
                type: .traffic,
                severity: .high,
                title: "Congestionamento na Marginal Tietê",
                description: "Trânsito intenso entre Ponte das Bandeiras e Ponte Cruzeiro do Sul. Tempo estimado de atraso: 30 minutos.",
                location: "Marginal Tietê - Zona Norte",
                coordinate: CLLocationCoordinate2D(latitude: -23.5231, longitude: -46.6476),
                createdAt: Date().addingTimeInterval(-1800), // 30 minutos atrás
                expiresAt: Date().addingTimeInterval(7200), // Expira em 2 horas
                isActive: true
            ),
            Alert(
                id: "alert-002",
                type: .weather,
                severity: .medium,
                title: "Possibilidade de Chuva Forte",
                description: "Previsão de chuva forte para as próximas 2 horas na região central.",
                location: "Centro - São Paulo",
                coordinate: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                createdAt: Date().addingTimeInterval(-600), // 10 minutos atrás
                expiresAt: Date().addingTimeInterval(7200),
                isActive: true
            ),
            Alert(
                id: "alert-003",
                type: .event,
                severity: .low,
                title: "Evento na Avenida Paulista",
                description: "Passeata programada para hoje às 18h. Possíveis interdições de vias.",
                location: "Avenida Paulista - Centro",
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6562),
                createdAt: Date().addingTimeInterval(-3600), // 1 hora atrás
                expiresAt: Date().addingTimeInterval(10800),
                isActive: true
            ),
            Alert(
                id: "alert-004",
                type: .infrastructure,
                severity: .medium,
                title: "Obra na Avenida Rebouças",
                description: "Manutenção de via com interdição de faixa. Reduza a velocidade.",
                location: "Avenida Rebouças - Pinheiros",
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6862),
                createdAt: Date().addingTimeInterval(-7200), // 2 horas atrás
                expiresAt: nil, // Sem data de expiração
                isActive: true
            ),
            Alert(
                id: "alert-005",
                type: .emergency,
                severity: .critical,
                title: "Acidente na Radial Leste",
                description: "Acidente grave envolvendo 3 veículos. Via parcialmente interditada. Desvie pela Rua da Mooca.",
                location: "Radial Leste - Tatuapé",
                coordinate: CLLocationCoordinate2D(latitude: -23.5422, longitude: -46.5756),
                createdAt: Date().addingTimeInterval(-300), // 5 minutos atrás
                expiresAt: Date().addingTimeInterval(3600),
                isActive: true
            )
        ]
    }

    static func mockAlertsDTO() -> AlertsResponseDTO {
        let alerts = [
            AlertDataDTO(
                id: "alert-001",
                type: "traffic",
                severity: "high",
                title: "Congestionamento na Marginal Tietê",
                description: "Trânsito intenso entre Ponte das Bandeiras e Ponte Cruzeiro do Sul. Tempo estimado de atraso: 30 minutos.",
                location: "Marginal Tietê - Zona Norte",
                latitude: -23.5231,
                longitude: -46.6476,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-002",
                type: "weather",
                severity: "medium",
                title: "Possibilidade de Chuva Forte",
                description: "Previsão de chuva forte para as próximas 2 horas na região central.",
                location: "Centro - São Paulo",
                latitude: -23.5505,
                longitude: -46.6333,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-600)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-003",
                type: "event",
                severity: "low",
                title: "Evento na Avenida Paulista",
                description: "Passeata programada para hoje às 18h. Possíveis interdições de vias.",
                location: "Avenida Paulista - Centro",
                latitude: -23.5617,
                longitude: -46.6562,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(10800)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-004",
                type: "infrastructure",
                severity: "medium",
                title: "Obra na Avenida Rebouças",
                description: "Manutenção de via com interdição de faixa. Reduza a velocidade.",
                location: "Avenida Rebouças - Pinheiros",
                latitude: -23.5617,
                longitude: -46.6862,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200)),
                expiresAt: nil,
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-005",
                type: "emergency",
                severity: "critical",
                title: "Acidente na Radial Leste",
                description: "Acidente grave envolvendo 3 veículos. Via parcialmente interditada. Desvie pela Rua da Mooca.",
                location: "Radial Leste - Tatuapé",
                latitude: -23.5422,
                longitude: -46.5756,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
                isActive: true
            )
        ]

        return AlertsResponseDTO(
            success: true,
            data: alerts,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Events Mock

    static func mockEvents() -> [Event] {
        [
            Event(
                id: "evt-001",
                title: "Festival de Música na Praça",
                description: "Grande festival com bandas locais e food trucks. Evento gratuito para toda a família com shows a partir das 19h.",
                category: .culture,
                location: "Praça Central",
                coordinate: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                startDate: Date().addingTimeInterval(86400 * 2), // Daqui 2 dias
                endDate: Date().addingTimeInterval(86400 * 2 + 14400), // 4 horas depois
                isAllDay: false,
                imageURL: nil,
                isFeatured: true,
                organizer: "Prefeitura Municipal",
                contactEmail: "cultura@cidade.gov.br",
                contactPhone: "(11) 1234-5678",
                ticketURL: nil,
                price: 0.0,
                city: "sao-paulo"
            ),
            Event(
                id: "evt-002",
                title: "Corrida 10K Cidade Viva",
                description: "Corrida de rua beneficente. Inscrições abertas até o dia do evento.",
                category: .sports,
                location: "Parque Municipal",
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6562),
                startDate: Date().addingTimeInterval(86400 * 7), // Daqui 7 dias
                endDate: nil,
                isAllDay: false,
                imageURL: nil,
                isFeatured: true,
                organizer: "Secretaria de Esportes",
                contactEmail: "esportes@cidade.gov.br",
                contactPhone: "(11) 9876-5432",
                ticketURL: "https://inscricoes.com/corrida",
                price: 50.0,
                city: "sao-paulo"
            ),
            Event(
                id: "evt-003",
                title: "Teatro Infantil - O Pequeno Príncipe",
                description: "Espetáculo teatral para crianças baseado no clássico de Saint-Exupéry.",
                category: .entertainment,
                location: "Teatro Municipal",
                coordinate: CLLocationCoordinate2D(latitude: -23.5733, longitude: -46.6417),
                startDate: Date().addingTimeInterval(86400 * 5), // Daqui 5 dias
                endDate: Date().addingTimeInterval(86400 * 5 + 5400), // 1h30min depois
                isAllDay: false,
                imageURL: nil,
                isFeatured: false,
                organizer: "Cia Teatral ABC",
                contactEmail: "contato@ciaabc.com.br",
                contactPhone: "(11) 5555-1234",
                ticketURL: "https://ingressos.com/teatro",
                price: 40.0,
                city: "sao-paulo"
            ),
            Event(
                id: "evt-004",
                title: "Feira de Artesanato",
                description: "Feira com artesanato local, produtos orgânicos e gastronomia regional.",
                category: .community,
                location: "Praça da Matriz",
                coordinate: CLLocationCoordinate2D(latitude: -23.5422, longitude: -46.5756),
                startDate: Date().addingTimeInterval(86400), // Amanhã
                endDate: Date().addingTimeInterval(86400 + 28800), // 8 horas depois
                isAllDay: true,
                imageURL: nil,
                isFeatured: false,
                organizer: "Associação de Artesãos",
                contactEmail: "artesaos@email.com",
                contactPhone: nil,
                ticketURL: nil,
                price: 0.0,
                city: "sao-paulo"
            )
        ]
    }

    static func mockEventsDTO() -> EventsResponseDTO {
        EventsResponseDTO(
            count: 4,
            next: nil,
            previous: nil,
            results: [
                EventDataDTO(
                    id: "evt-001",
                    title: "Festival de Música na Praça",
                    description: "Grande festival com bandas locais e food trucks. Evento gratuito para toda a família.",
                    category: "culture",
                    locationName: "Praça Central",
                    latitude: -23.5505,
                    longitude: -46.6333,
                    startDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 2)),
                    endDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 2 + 14400)),
                    allDay: false,
                    image: nil,
                    isFeatured: true,
                    organizer: "Prefeitura Municipal",
                    contactEmail: "cultura@cidade.gov.br",
                    contactPhone: "(11) 1234-5678",
                    ticketURL: nil,
                    price: 0.0,
                    city: "sao-paulo",
                    createdAt: ISO8601DateFormatter().string(from: Date())
                ),
                EventDataDTO(
                    id: "evt-002",
                    title: "Corrida 10K Cidade Viva",
                    description: "Corrida de rua beneficente. Inscrições abertas até o dia do evento.",
                    category: "sports",
                    locationName: "Parque Municipal",
                    latitude: -23.5617,
                    longitude: -46.6562,
                    startDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 7)),
                    endDate: nil,
                    allDay: false,
                    image: nil,
                    isFeatured: true,
                    organizer: "Secretaria de Esportes",
                    contactEmail: "esportes@cidade.gov.br",
                    contactPhone: "(11) 9876-5432",
                    ticketURL: "https://inscricoes.com/corrida",
                    price: 50.0,
                    city: "sao-paulo",
                    createdAt: ISO8601DateFormatter().string(from: Date())
                ),
                EventDataDTO(
                    id: "evt-003",
                    title: "Teatro Infantil - O Pequeno Príncipe",
                    description: "Espetáculo teatral para crianças baseado no clássico de Saint-Exupéry.",
                    category: "entertainment",
                    locationName: "Teatro Municipal",
                    latitude: -23.5733,
                    longitude: -46.6417,
                    startDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 5)),
                    endDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 5 + 5400)),
                    allDay: false,
                    image: nil,
                    isFeatured: false,
                    organizer: "Cia Teatral ABC",
                    contactEmail: "contato@ciaabc.com.br",
                    contactPhone: "(11) 5555-1234",
                    ticketURL: "https://ingressos.com/teatro",
                    price: 40.0,
                    city: "sao-paulo",
                    createdAt: ISO8601DateFormatter().string(from: Date())
                ),
                EventDataDTO(
                    id: "evt-004",
                    title: "Feira de Artesanato",
                    description: "Feira com artesanato local, produtos orgânicos e gastronomia regional.",
                    category: "community",
                    locationName: "Praça da Matriz",
                    latitude: -23.5422,
                    longitude: -46.5756,
                    startDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)),
                    endDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 + 28800)),
                    allDay: true,
                    image: nil,
                    isFeatured: false,
                    organizer: "Associação de Artesãos",
                    contactEmail: "artesaos@email.com",
                    contactPhone: nil,
                    ticketURL: nil,
                    price: 0.0,
                    city: "sao-paulo",
                    createdAt: ISO8601DateFormatter().string(from: Date())
                )
            ]
        )
    }

    // MARK: - News Mock

    static func mockNews() -> [News] {
        [
            News(
                id: "news-001",
                title: "Nova ciclovia inaugurada na Av. Principal",
                summary: "Prefeitura inaugura 5km de ciclovia conectando zona sul ao centro da cidade.",
                content: "A Prefeitura inaugurou hoje 5km de ciclovia na Avenida Principal, conectando a zona sul ao centro da cidade. A nova infraestrutura faz parte do plano de mobilidade urbana e deve beneficiar milhares de ciclistas diariamente.",
                imageURL: nil,
                publishedAt: Date().addingTimeInterval(-3600), // 1 hora atrás
                expiresAt: Date().addingTimeInterval(2592000), // 30 dias
                isFeatured: true,
                category: "Transporte",
                author: "Assessoria de Imprensa",
                sourceURL: "https://cidade.gov.br/noticias/ciclovia",
                city: "sao-paulo"
            ),
            News(
                id: "news-002",
                title: "Vacinação contra gripe começa na próxima semana",
                summary: "Campanha de vacinação inicia segunda-feira em todas as UBS da cidade.",
                content: "A campanha de vacinação contra a gripe começa na próxima segunda-feira em todas as Unidades Básicas de Saúde da cidade. Grupos prioritários serão atendidos primeiro.",
                imageURL: nil,
                publishedAt: Date().addingTimeInterval(-7200), // 2 horas atrás
                expiresAt: Date().addingTimeInterval(604800), // 7 dias
                isFeatured: true,
                category: "Saúde",
                author: "Secretaria de Saúde",
                sourceURL: nil,
                city: "sao-paulo"
            ),
            News(
                id: "news-003",
                title: "Parque Municipal recebe melhorias",
                summary: "Área de lazer ganha novos brinquedos e iluminação LED.",
                content: "O Parque Municipal recebeu melhorias com instalação de novos brinquedos, iluminação LED e reforma dos sanitários. As obras foram concluídas esta semana.",
                imageURL: nil,
                publishedAt: Date().addingTimeInterval(-86400), // 1 dia atrás
                expiresAt: nil,
                isFeatured: false,
                category: "Infraestrutura",
                author: "Redação",
                sourceURL: nil,
                city: "sao-paulo"
            )
        ]
    }

    static func mockNewsDTO() -> NewsResponseDTO {
        NewsResponseDTO(
            count: 3,
            next: nil,
            previous: nil,
            results: [
                NewsDataDTO(
                    id: "news-001",
                    title: "Nova ciclovia inaugurada na Av. Principal",
                    summary: "Prefeitura inaugura 5km de ciclovia conectando zona sul ao centro da cidade.",
                    content: "A Prefeitura inaugurou hoje 5km de ciclovia na Avenida Principal...",
                    image: nil,
                    publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                    expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(2592000)),
                    isFeatured: true,
                    category: "Transporte",
                    author: "Assessoria de Imprensa",
                    sourceURL: "https://cidade.gov.br/noticias/ciclovia",
                    city: "sao-paulo"
                ),
                NewsDataDTO(
                    id: "news-002",
                    title: "Vacinação contra gripe começa na próxima semana",
                    summary: "Campanha de vacinação inicia segunda-feira em todas as UBS da cidade.",
                    content: "A campanha de vacinação contra a gripe começa na próxima segunda-feira...",
                    image: nil,
                    publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200)),
                    expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(604800)),
                    isFeatured: true,
                    category: "Saúde",
                    author: "Secretaria de Saúde",
                    sourceURL: nil,
                    city: "sao-paulo"
                ),
                NewsDataDTO(
                    id: "news-003",
                    title: "Parque Municipal recebe melhorias",
                    summary: "Área de lazer ganha novos brinquedos e iluminação LED.",
                    content: "O Parque Municipal recebeu melhorias...",
                    image: nil,
                    publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
                    expiresAt: nil,
                    isFeatured: false,
                    category: "Infraestrutura",
                    author: "Redação",
                    sourceURL: nil,
                    city: "sao-paulo"
                )
            ]
        )
    }

    // MARK: - POIs Mock

    static func mockPOIs() -> [PointOfInterest] {
        [
            PointOfInterest(
                id: "poi-001",
                name: "Hospital Municipal Central",
                description: "Hospital público com atendimento 24h de emergência e especialidades.",
                type: .hospital,
                address: "Rua das Flores, 123 - Centro",
                coordinate: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                phone: "(11) 1234-5678",
                email: "contato@hospitalmunicipal.gov.br",
                website: "https://hospitalmunicipal.gov.br",
                imageURL: nil,
                openingHours: "24 horas",
                rating: 4.5,
                city: "sao-paulo"
            ),
            PointOfInterest(
                id: "poi-002",
                name: "Restaurante Sabor da Terra",
                description: "Culinária regional com pratos típicos e ambiente familiar.",
                type: .restaurant,
                address: "Av. Principal, 456 - Centro",
                coordinate: CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6562),
                phone: "(11) 9876-5432",
                email: "contato@sabordaterra.com.br",
                website: nil,
                imageURL: nil,
                openingHours: "Seg-Sáb: 11h-22h, Dom: 11h-16h",
                rating: 4.8,
                city: "sao-paulo"
            ),
            PointOfInterest(
                id: "poi-003",
                name: "Hotel Centro Plaza",
                description: "Hotel executivo no centro da cidade com WiFi e café da manhã inclusos.",
                type: .hotel,
                address: "Rua do Comércio, 789 - Centro",
                coordinate: CLLocationCoordinate2D(latitude: -23.5733, longitude: -46.6417),
                phone: "(11) 5555-9999",
                email: "reservas@centroplaza.com.br",
                website: "https://centroplaza.com.br",
                imageURL: nil,
                openingHours: "Recepção 24h",
                rating: 4.2,
                city: "sao-paulo"
            ),
            PointOfInterest(
                id: "poi-004",
                name: "Museu de História da Cidade",
                description: "Acervo permanente sobre a história e cultura local.",
                type: .attraction,
                address: "Praça da Cultura, s/n - Centro",
                coordinate: CLLocationCoordinate2D(latitude: -23.5422, longitude: -46.5756),
                phone: "(11) 3333-4444",
                email: "museu@cultura.gov.br",
                website: "https://museuhistoria.gov.br",
                imageURL: nil,
                openingHours: "Ter-Dom: 9h-17h (Segunda fechado)",
                rating: 4.7,
                city: "sao-paulo"
            ),
            PointOfInterest(
                id: "poi-005",
                name: "Terminal Rodoviário Central",
                description: "Terminal rodoviário com linhas urbanas e intermunicipais.",
                type: .transport,
                address: "Av. dos Transportes, 1000 - Rodoviária",
                coordinate: CLLocationCoordinate2D(latitude: -23.5989, longitude: -46.6622),
                phone: "(11) 2222-3333",
                email: "terminal@transporte.gov.br",
                website: nil,
                imageURL: nil,
                openingHours: "24 horas",
                rating: 3.9,
                city: "sao-paulo"
            )
        ]
    }

    static func mockPOIsDTO() -> POIsResponseDTO {
        POIsResponseDTO(
            count: 5,
            next: nil,
            previous: nil,
            results: [
                POIDataDTO(
                    id: "poi-001",
                    name: "Hospital Municipal Central",
                    description: "Hospital público com atendimento 24h de emergência.",
                    type: "hospital",
                    address: "Rua das Flores, 123 - Centro",
                    latitude: -23.5505,
                    longitude: -46.6333,
                    phone: "(11) 1234-5678",
                    email: "contato@hospitalmunicipal.gov.br",
                    website: "https://hospitalmunicipal.gov.br",
                    image: nil,
                    openingHours: "24 horas",
                    rating: 4.5,
                    city: "sao-paulo"
                ),
                POIDataDTO(
                    id: "poi-002",
                    name: "Restaurante Sabor da Terra",
                    description: "Culinária regional com pratos típicos.",
                    type: "restaurant",
                    address: "Av. Principal, 456 - Centro",
                    latitude: -23.5617,
                    longitude: -46.6562,
                    phone: "(11) 9876-5432",
                    email: "contato@sabordaterra.com.br",
                    website: nil,
                    image: nil,
                    openingHours: "Seg-Sáb: 11h-22h",
                    rating: 4.8,
                    city: "sao-paulo"
                ),
                POIDataDTO(
                    id: "poi-003",
                    name: "Hotel Centro Plaza",
                    description: "Hotel executivo no centro.",
                    type: "hotel",
                    address: "Rua do Comércio, 789 - Centro",
                    latitude: -23.5733,
                    longitude: -46.6417,
                    phone: "(11) 5555-9999",
                    email: "reservas@centroplaza.com.br",
                    website: "https://centroplaza.com.br",
                    image: nil,
                    openingHours: "Recepção 24h",
                    rating: 4.2,
                    city: "sao-paulo"
                ),
                POIDataDTO(
                    id: "poi-004",
                    name: "Museu de História da Cidade",
                    description: "Acervo sobre a história local.",
                    type: "attraction",
                    address: "Praça da Cultura, s/n - Centro",
                    latitude: -23.5422,
                    longitude: -46.5756,
                    phone: "(11) 3333-4444",
                    email: "museu@cultura.gov.br",
                    website: "https://museuhistoria.gov.br",
                    image: nil,
                    openingHours: "Ter-Dom: 9h-17h",
                    rating: 4.7,
                    city: "sao-paulo"
                ),
                POIDataDTO(
                    id: "poi-005",
                    name: "Terminal Rodoviário Central",
                    description: "Terminal com linhas urbanas.",
                    type: "transport",
                    address: "Av. dos Transportes, 1000",
                    latitude: -23.5989,
                    longitude: -46.6622,
                    phone: "(11) 2222-3333",
                    email: "terminal@transporte.gov.br",
                    website: nil,
                    image: nil,
                    openingHours: "24 horas",
                    rating: 3.9,
                    city: "sao-paulo"
                )
            ]
        )
    }
}
