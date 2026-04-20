import Foundation
import Moya

enum AuthAPI {
    case login(String, String)
    case register(String, String)
    case logout(String)
    case refreshToken(String)
    case userInfo
}

extension AuthAPI: APITargetType {
    
    var path: String {
        switch self {
        case .login:
            return "/v3/auth/sign_in"
        case .register:
            return "/auth/register"
        case .logout:
            return "/v3/auth/sign_out"
        case .refreshToken:
            return "/auth/refresh"
        case .userInfo:
            return "/v3/dd/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .register, .logout, .refreshToken:
            return .post
        case .userInfo:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .login(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password],
                                      encoding: JSONEncoding.default)
            
        case .register(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password],
                                      encoding: JSONEncoding.default)
            
        case .logout(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
            
        case .refreshToken(let refreshToken):
            return .requestParameters(parameters: ["refresh_token": refreshToken],
                                      encoding: JSONEncoding.default)
            
        case .userInfo:
            return .requestPlain
        }
    }
    
    var shouldShowLoading: Bool {
        switch self {
        case .logout:
            return false
        case .refreshToken:
            return false
        default:
            return true
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .register, .refreshToken:
            return false
        case .logout, .userInfo:
            return true
        }
    }
}
