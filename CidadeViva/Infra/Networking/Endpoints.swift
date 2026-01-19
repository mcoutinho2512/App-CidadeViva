import Foundation

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: [String: Any]?
    let headers: [String: String]

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        body: [String: Any]? = nil,
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }

    var url: URL? {
        var components = URLComponents(string: AppConfiguration.fullAPIURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum Endpoints {
    static var weather: Endpoint {
        Endpoint(path: "/weather")
    }

    static var cameras: Endpoint {
        Endpoint(path: "/cameras")
    }

    static var alerts: Endpoint {
        Endpoint(path: "/alerts")
    }

    static var events: Endpoint {
        Endpoint(path: "/events")
    }

    static var news: Endpoint {
        Endpoint(path: "/news")
    }

    static var pois: Endpoint {
        Endpoint(path: "/pois")
    }

    static func pois(category: String) -> Endpoint {
        Endpoint(
            path: "/pois",
            queryItems: [URLQueryItem(name: "category", value: category)]
        )
    }

    static func route(from origin: Location, to destination: Location) -> Endpoint {
        Endpoint(
            path: "/routes",
            queryItems: [
                URLQueryItem(name: "originLat", value: String(origin.latitude)),
                URLQueryItem(name: "originLng", value: String(origin.longitude)),
                URLQueryItem(name: "destLat", value: String(destination.latitude)),
                URLQueryItem(name: "destLng", value: String(destination.longitude))
            ]
        )
    }
}
