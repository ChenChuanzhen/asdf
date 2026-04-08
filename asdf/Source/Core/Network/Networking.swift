import Foundation
import Moya

// MARK: - Networking

struct Networking {
    
    /// Create a provider with default plugins (Logger, Loading)
    static func newProvider<T: TargetType>() -> MoyaProvider<T> {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            LoadingPlugin()
        ]
        
        return MoyaProvider<T>(plugins: plugins)
    }
}

// MARK: - APIError

enum APIError: Error {
    case unknown
    case message(String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error occurred"
        case .message(let msg):
            return msg
        }
    }
}
