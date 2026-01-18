//
//  NetworkError.swift
//  CidadeViva
//
//  Definição de erros de rede
//

import Foundation

/// Erros possíveis de rede
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case noData
    case timeout
    case noInternetConnection
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .requestFailed(let error):
            return "Falha na requisição: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Erro ao processar dados: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Erro no servidor (código \(statusCode))"
        case .noData:
            return "Nenhum dado recebido"
        case .timeout:
            return "Tempo de requisição esgotado"
        case .noInternetConnection:
            return "Sem conexão com a internet"
        case .unknown:
            return "Erro desconhecido"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Verifique sua conexão com a internet e tente novamente."
        case .timeout:
            return "A requisição demorou muito. Tente novamente."
        case .serverError:
            return "O servidor está temporariamente indisponível. Tente novamente mais tarde."
        default:
            return "Tente novamente. Se o problema persistir, entre em contato com o suporte."
        }
    }
}
