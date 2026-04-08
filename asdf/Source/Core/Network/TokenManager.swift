import Foundation

final class TokenManager {
    
    static let shared = TokenManager()
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let tokenExpirationKey = "token_expiration"
    
    private init() {}
    
    var accessToken: String? {
        get {
            let token = UserDefaults.standard.string(forKey: accessTokenKey)
            if let token = token {
                print("✅ Access token retrieved from disk: \(String(token.prefix(20)))...")
            } else {
                print("❌ No access token found in disk")
            }
            return token
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: accessTokenKey)
                print("✅ Access token saved to disk: \(String(token.prefix(20)))...")
            } else {
                UserDefaults.standard.removeObject(forKey: accessTokenKey)
                print("❌ Access token removed from disk")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var refreshToken: String? {
        get {
            let token = UserDefaults.standard.string(forKey: refreshTokenKey)
            if let token = token {
                print("✅ Refresh token retrieved from disk: \(String(token.prefix(20)))...")
            } else {
                print("❌ No refresh token found in disk")
            }
            return token
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: refreshTokenKey)
                print("✅ Refresh token saved to disk: \(String(token.prefix(20)))...")
            } else {
                UserDefaults.standard.removeObject(forKey: refreshTokenKey)
                print("❌ Refresh token removed from disk")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var tokenExpiration: Date? {
        get {
            let expiration = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date
            if let expiration = expiration {
                print("✅ Token expiration retrieved from disk: \(expiration)")
            } else {
                print("❌ No token expiration found in disk")
            }
            return expiration
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: tokenExpirationKey)
                print("✅ Token expiration saved to disk: \(date)")
            } else {
                UserDefaults.standard.removeObject(forKey: tokenExpirationKey)
                print("❌ Token expiration removed from disk")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var isTokenValid: Bool {
        guard let expiration = tokenExpiration else {
            return false
        }
        return expiration > Date()
    }
    
    var isTokenExpired: Bool {
        !isTokenValid
    }
    
    var shouldRefreshToken: Bool {
        guard let expiration = tokenExpiration else {
            return false
        }
        let refreshThreshold: TimeInterval = 300
        return expiration.timeIntervalSinceNow < refreshThreshold
    }
    
    func saveTokens(accessToken: String, refreshToken: String, expiresIn: TimeInterval) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiration = Date().addingTimeInterval(expiresIn)
        print("✅ Tokens saved to disk successfully")
        print("   - Access Token: \(String(accessToken.prefix(20)))...")
        print("   - Refresh Token: \(String(refreshToken.prefix(20)))...")
        print("   - Expires At: \(Date().addingTimeInterval(expiresIn))")
    }
    
    func clearTokens() {
        print("⚠️ Clearing all tokens from disk (logout)...")
        accessToken = nil
        refreshToken = nil
        tokenExpiration = nil
        print("✅ Tokens cleared from disk successfully")
    }
    
    func getAuthorizationHeader() -> String? {
        guard let token = accessToken else {
            return nil
        }
        return "Bearer \(token)"
    }
    
    func refreshAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = refreshToken else {
            completion(.failure(TokenError.noRefreshToken))
            return
        }
        
        NetworkManager.shared.request(AuthAPI.refreshToken(refreshToken),
                                      modelType: TokenResponse.self,
                                      showLoading: false) { tokenResponse in
            self.saveTokens(accessToken: tokenResponse.accessToken,
                           refreshToken: tokenResponse.refreshToken ?? refreshToken,
                           expiresIn: tokenResponse.expiresIn)
            completion(.success(tokenResponse.accessToken))
        } failure: { errorMessage in
            completion(.failure(TokenError.refreshFailed(errorMessage)))
        }
    }
}

enum TokenError: LocalizedError {
    case noRefreshToken
    case refreshFailed(String)
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .refreshFailed(let message):
            return "Failed to refresh token: \(message)"
        case .tokenExpired:
            return "Token has expired"
        }
    }
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
