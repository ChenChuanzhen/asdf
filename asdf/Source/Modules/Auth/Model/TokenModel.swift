import Foundation

struct TokenModel: Decodable {
    let idToken: String
    let scope: String
    let tokenType: String
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case scope
        case tokenType = "token_type"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
    
    var expiresIn: TimeInterval {
        return max(0, expiresAt - Date().timeIntervalSince1970)
    }
    
    var expirationDate: Date {
        return Date(timeIntervalSince1970: expiresAt)
    }
    
    func isExpired() -> Bool {
        return Date().timeIntervalSince1970 >= expiresAt
    }
    
    func willExpire(within seconds: TimeInterval = 300) -> Bool {
        let timeUntilExpiry = expiresAt - Date().timeIntervalSince1970
        return timeUntilExpiry <= seconds
    }
}
