import Foundation
import Moya

/// Extended protocol to include loading indicator configuration
protocol APITargetType: TargetType {
    var shouldShowLoading: Bool { get }
    var requiresAuth: Bool { get }
}

extension APITargetType {
    
    var baseURL: URL {
        return AppConfig.baseURL
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var shouldShowLoading: Bool {
        return true
    }
    
    var requiresAuth: Bool {
        return false
    }
}
