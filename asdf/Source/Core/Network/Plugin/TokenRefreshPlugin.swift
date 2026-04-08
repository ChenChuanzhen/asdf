import Foundation
import Moya

final class TokenRefreshPlugin: PluginType {
    
    private var isRefreshing = false
    private var requestsToRetry: [(TargetType) -> Void] = []
    private let lock = NSLock()
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        let apiTarget: APITargetType?
        if let multiTarget = target as? MultiTarget {
            apiTarget = multiTarget.target as? APITargetType
        } else {
            apiTarget = target as? APITargetType
        }
        
        guard let apiTarget = apiTarget, apiTarget.requiresAuth else {
            return result
        }
        
        if case .success(let response) = result, response.statusCode == 401 {
            return .failure(MoyaError.statusCode(response))
        }
        
        return result
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        let apiTarget: APITargetType?
        if let multiTarget = target as? MultiTarget {
            apiTarget = multiTarget.target as? APITargetType
        } else {
            apiTarget = target as? APITargetType
        }
        
        guard let apiTarget = apiTarget, apiTarget.requiresAuth else {
            return
        }
        
        if case .failure(let error) = result {
            if let response = error.response, response.statusCode == 401 {
                handleUnauthorizedRequest(target: target)
            }
        }
    }
    
    private func handleUnauthorizedRequest(target: TargetType) {
        lock.lock()
        
        if isRefreshing {
            requestsToRetry.append { [weak self] _ in
                self?.retryRequest(target: target)
            }
            lock.unlock()
            return
        }
        
        isRefreshing = true
        lock.unlock()
        
        TokenManager.shared.refreshAccessToken { [weak self] result in
            guard let self = self else { return }
            
            self.lock.lock()
            self.isRefreshing = false
            
            switch result {
            case .success:
                self.requestsToRetry.forEach { $0(target) }
            case .failure:
                TokenManager.shared.clearTokens()
                NotificationCenter.default.post(name: .tokenExpired, object: nil)
            }
            
            self.requestsToRetry.removeAll()
            self.lock.unlock()
        }
    }
    
    private func retryRequest(target: TargetType) {
        NetworkManager.shared.request(target,
                                      modelType: EmptyResponse.self,
                                      showLoading: false) { _ in } failure: { _ in }
    }
}


