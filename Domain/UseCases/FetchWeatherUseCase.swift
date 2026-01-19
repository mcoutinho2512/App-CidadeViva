//
//  FetchWeatherUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar dados climáticos
//

import Foundation

/// Caso de uso para buscar informações climáticas
final class FetchWeatherUseCase {

    // MARK: - Properties

    private let repository: WeatherRepositoryProtocol

    // MARK: - Initialization

    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de dados climáticos
    func execute() async throws -> Weather {
        try await repository.fetchCurrentWeather()
    }
}
