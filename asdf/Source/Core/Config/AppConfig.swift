import Foundation

enum AppEnvironment {
    case development
    case production
}

struct AppConfig {
    
    // Determine environment based on Build Configuration
    #if DEBUG
    static let environment: AppEnvironment = .development
    #else
    static let environment: AppEnvironment = .production
    #endif
    
    static var baseURL: URL {
        switch environment {
        case .development:
            return URL(string: "https://api.staging.kenangadigital.com")!
        case .production:
            return URL(string: "https://api.staging.kenangadigital.com")!
        }
    }
    
    static let timeoutInterval: TimeInterval = 30.0
    
    struct Keys {
        // Add API Keys or other secrets here
        // static let apiKey = "..."
    }
}
