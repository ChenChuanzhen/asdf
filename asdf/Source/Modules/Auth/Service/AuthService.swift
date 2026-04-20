import Foundation
import Moya

/// Auth Service - Application Layer for Auth Module
final class AuthService {
    
    static let shared = AuthService()
    
    /*
    /// Login with dynamic loading control
    func login(username: String,
               pass: String,
               showLoading: Bool = true,
               success: @escaping (TokenModel) -> Void,
               failure: @escaping (String) -> Void) {
        
        NetworkManager.shared.request(AuthAPI.login(username, pass),
                                      modelType: TokenModel.self,
                                      showLoading: showLoading,
                                      success: { tokenModel in
            TokenManager.shared.saveTokens(accessToken: tokenModel.accessToken, refreshToken: tokenModel.refreshToken, expiresIn: tokenModel.expiresIn)
            success(tokenModel)
        },
                                      failure: failure)
    }
    
    func register(username: String, pass: String, showLoading: Bool = true,
                  success: @escaping (UserModel) -> Void, failure: @escaping (String) -> Void) {
        
        NetworkManager.shared.request(AuthAPI.register(username, pass),
                                      modelType: UserModel.self,
                                      showLoading: showLoading,
                                      success: success,
                                      failure: failure)
    }
    
    func logout(showLoading: Bool = true, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.request(AuthAPI.logout,
                                      modelType: EmptyResponse.self,
                                      showLoading: showLoading,
                                      success: { _ in
            TokenManager.shared.clearTokens()
            UserManager.shared.clearUser()
            completion(true)
        },
                                      failure: { _ in
            TokenManager.shared.clearTokens()
            UserManager.shared.clearUser()
            completion(false)
        })
    }
    
    func userInfo(showLoading: Bool = true, completion: @escaping (UserModel?) -> Void) {
        
        NetworkManager.shared.request(AuthAPI.userInfo, modelType: UserModel.self, showLoading: showLoading) { user in
            completion(user)
        } failure: { string in
            completion(nil)
        }
    }
    */
    
    /// Login with async/await while keeping token persistence in one place
    func login(username: String, pass: String, showLoading: Bool = true) async throws -> TokenModel {
        let tokenModel = try await NetworkManager.shared.requestAsync(AuthAPI.login(username, pass), modelType: TokenModel.self, showLoading: showLoading)
        TokenManager.shared.saveTokens(accessToken: tokenModel.accessToken, refreshToken: tokenModel.refreshToken, expiresIn: tokenModel.expiresIn)
        return tokenModel
    }
    
    func register(username: String,
                  pass: String,
                  showLoading: Bool = true) async throws -> UserModel {
        try await NetworkManager.shared.requestAsync(AuthAPI.register(username, pass),
                                                     modelType: UserModel.self,
                                                     showLoading: showLoading)
    }
    
    func logout(token:String, showLoading: Bool = true) async -> Bool {
        do {
            _ = try await NetworkManager.shared.requestAsync(AuthAPI.logout(token),
                                                             modelType: EmptyResponse.self,
                                                             showLoading: showLoading)
            TokenManager.shared.clearTokens()
            UserManager.shared.clearUser()
            return true
        } catch {
            return false
        }
    }
    
    func userInfo(showLoading: Bool = true) async throws -> UserModel {
        try await NetworkManager.shared.requestAsync(AuthAPI.userInfo,
                                                     modelType: UserModel.self,
                                                     showLoading: showLoading)
    }
}
