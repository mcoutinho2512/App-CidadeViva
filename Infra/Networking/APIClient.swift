//
//  APIClient.swift
//  CidadeViva
//
//  Cliente genérico para requisições de rede
//  Implementa async/await com tratamento completo de erros
//

import Foundation

/// Cliente de API genérico com suporte a async/await
final class APIClient {

    // MARK: - Properties

    private let session: URLSession
    private let timeout: TimeInterval

    // MARK: - Initialization

    init(timeout: TimeInterval = AppConfiguration.API.timeout) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)
        self.timeout = timeout
    }

    // MARK: - Public Methods

    /// Realiza uma requisição GET genérica
    /// - Parameters:
    ///   - endpoint: Endpoint da API
    ///   - responseType: Tipo esperado de resposta (Decodable)
    /// - Returns: Objeto decodificado do tipo especificado
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        // Se dados mockados estão habilitados, retorna mock
        if AppConfiguration.Features.enableMockData {
            return try await performMockRequest(endpoint: endpoint, responseType: responseType)
        }

        // Requisição real
        return try await performRealRequest(endpoint: endpoint, responseType: responseType)
    }

    // MARK: - Real Request

    /// Realiza requisição real para a API
    private func performRealRequest<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        #if DEBUG
        if AppConfiguration.Features.enableNetworkLogging {
            print("🌐 [APIClient] Request: \(endpoint.method.rawValue) \(url.absoluteString)")
        }
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            #if DEBUG
            if AppConfiguration.Features.enableNetworkLogging {
                print("🌐 [APIClient] Response: \(httpResponse.statusCode)")
            }
            #endif

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                #if DEBUG
                if AppConfiguration.Features.enableNetworkLogging {
                    print("❌ [APIClient] Decoding error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 [APIClient] Response data: \(jsonString)")
                    }
                }
                #endif
                throw NetworkError.decodingFailed(error)
            }

        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw NetworkError.noInternetConnection
            } else if urlError.code == .timedOut {
                throw NetworkError.timeout
            } else {
                throw NetworkError.requestFailed(urlError)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    // MARK: - Mock Request

    /// Realiza requisição mockada (para desenvolvimento)
    private func performMockRequest<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        #if DEBUG
        if AppConfiguration.Features.enableNetworkLogging {
            print("🔶 [APIClient] Using MOCK data for endpoint: \(endpoint.path)")
        }
        #endif

        // Simula delay de rede (200-500ms)
        let delay = UInt64.random(in: 200_000_000...500_000_000) // nanosegundos
        try await Task.sleep(nanoseconds: delay)

        // Retorna dados mockados baseados no endpoint
        switch endpoint {
        case .weather:
            if let mockData = MockData.mockWeatherDTO() as? T {
                return mockData
            }
        case .cameras:
            if let mockData = MockData.mockCamerasDTO() as? T {
                return mockData
            }
        case .alerts:
            if let mockData = MockData.mockAlertsDTO() as? T {
                return mockData
            }
        case .events, .eventsUpcoming, .eventsFeatured:
            if let mockData = MockData.mockEventsDTO() as? T {
                return mockData
            }
        case .news, .newsFeatured:
            if let mockData = MockData.mockNewsDTO() as? T {
                return mockData
            }
        case .pois, .poisNearby:
            if let mockData = MockData.mockPOIsDTO() as? T {
                return mockData
            }
        case .navigationRoute:
            // Rotas são calculadas dinamicamente no repository
            throw NetworkError.noData
        }

        throw NetworkError.noData
    }
}
