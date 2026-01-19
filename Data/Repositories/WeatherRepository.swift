//
//  WeatherRepository.swift
//  CidadeViva
//
//  Repositório para dados de clima
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation

/// Protocolo do repositório de clima
protocol WeatherRepositoryProtocol {
    func fetchCurrentWeather() async throws -> Weather
}

/// Implementação do repositório de clima
final class WeatherRepository: WeatherRepositoryProtocol {

    // MARK: - Properties

    private let apiClient: APIClient
    private let cacheService: CacheService

    // MARK: - Initialization

    init(
        apiClient: APIClient = APIClient(),
        cacheService: CacheService = .shared
    ) {
        self.apiClient = apiClient
        self.cacheService = cacheService
    }

    // MARK: - Public Methods

    /// Busca dados climáticos atuais
    func fetchCurrentWeather() async throws -> Weather {
        // Tenta buscar do cache primeiro
        if let cachedWeather: Weather = cacheService.get(forKey: CacheService.CacheKey.weather) {
            #if DEBUG
            print("☁️ [WeatherRepository] Returning cached weather data")
            #endif
            return cachedWeather
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .weather,
            responseType: WeatherResponseDTO.self
        )

        guard let weather = response.data.toDomain() else {
            throw NetworkError.decodingFailed(
                NSError(domain: "WeatherRepository", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Falha ao converter dados de clima"
                ])
            )
        }

        // Salva no cache
        cacheService.set(weather, forKey: CacheService.CacheKey.weather)

        return weather
    }
}
