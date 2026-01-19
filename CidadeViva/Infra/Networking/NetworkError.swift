import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case unauthorized
    case serverError
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .httpError(let statusCode):
            return "Erro HTTP: \(statusCode)"
        case .decodingError:
            return "Erro ao processar dados"
        case .noData:
            return "Nenhum dado recebido"
        case .unauthorized:
            return "Não autorizado"
        case .serverError:
            return "Erro no servidor"
        case .noConnection:
            return "Sem conexão com a internet"
        }
    }
}
