import Foundation
import Moya

final class AuthPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let multiTarget = target as? MultiTarget {
            if let apiTarget = multiTarget.target as? APITargetType, apiTarget.requiresAuth {
                if let authHeader = TokenManager.shared.getAuthorizationHeader() {
                    request.addValue(authHeader, forHTTPHeaderField: "Authorization")
                }
            }
        } else if let apiTarget = target as? APITargetType, apiTarget.requiresAuth {
            if let authHeader = TokenManager.shared.getAuthorizationHeader() {
                request.addValue(authHeader, forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
}
