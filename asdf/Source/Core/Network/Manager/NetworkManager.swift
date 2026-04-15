import Foundation
import Moya
import SVProgressHUD

/// Completion handler type alias
typealias APICompletion<T> = (Result<T, Error>) -> Void

/// Generic Network Manager Layer
class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let provider = MoyaProvider<MultiTarget>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        AuthPlugin(),
        TokenRefreshPlugin()
    ])
    
    func request<T: Decodable>(_ target: TargetType,
                               modelType: T.Type,
                               showLoading: Bool = true,
                               success: @escaping (T) -> Void,
                               failure: @escaping (String) -> Void) {
        
        if showLoading {
            showLoadingView()
        }
        
        provider.request(MultiTarget(target)) { result in
            if showLoading {
                self.hiddenLoadingView()
            }
            
            switch result {
            case .success(let response):
                do {
                    guard 200...299 ~= response.statusCode else {
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: response.data) {
                            failure(errorResponse.message)
                        } else {
                            failure("Request failed with status: \(response.statusCode)")
                        }
                        return
                    }
                    
                    let data = try response.map(T.self)
                    success(data)
                    
                } catch {
                    failure("Data parsing failed: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Batch Request
    
    func batchRequest<T: Decodable>(_ targets: [TargetType],
                                    modelTypes: [T.Type],
                                    showLoading: Bool = true,
                                    completion: @escaping ([Result<T, Error>]) -> Void) {
        
        if showLoading {
            showLoadingView()
        }
        
        let group = DispatchGroup()
        var results: [Result<T, Error>] = []
        let lock = NSLock()
        
        for (index, target) in targets.enumerated() {
            guard index < modelTypes.count else {
                lock.lock()
                results.append(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model type count mismatch"])))
                lock.unlock()
                continue
            }
            
            group.enter()
            provider.request(MultiTarget(target)) { result in
                lock.lock()
                defer { lock.unlock() }
                
                switch result {
                case .success(let response):
                    do {
                        guard 200...299 ~= response.statusCode else {
                            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: response.data) {
                                results.append(.failure(NSError(domain: "NetworkManager", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])))
                            } else {
                                results.append(.failure(NSError(domain: "NetworkManager", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status: \(response.statusCode)"])))
                            }
                            return
                        }
                        
                        let modelType = modelTypes[index]
                        let data = try response.map(modelType)
                        results.append(.success(data))
                    } catch {
                        results.append(.failure(error))
                    }
                case .failure(let error):
                    results.append(.failure(error))
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if showLoading {
                self.hiddenLoadingView()
            }
            completion(results)
        }
    }
    
    // MARK: - Async/Await Support
    
    @available(iOS 15.0, *)
    func requestAsync<T: Decodable>(_ target: TargetType,
                                    modelType: T.Type,
                                    showLoading: Bool = false) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target, modelType: modelType, showLoading: showLoading,
                        success: { continuation.resume(returning: $0) },
                        failure: { continuation.resume(throwing: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: $0])) })
        }
    }
    
    @available(iOS 15.0, *)
    func batchRequestAsync<T: Decodable>(_ targets: [TargetType],
                                        modelTypes: [T.Type],
                                        showLoading: Bool = true) async throws -> [T] {
        if showLoading {
            await MainActor.run {
                showLoadingView()
            }
        }
        
        defer {
            if showLoading {
                DispatchQueue.main.async { [weak self] in
                    self?.hiddenLoadingView()
                }
            }
        }
        
        var results: [T] = []
        for (index, target) in targets.enumerated() {
            guard index < modelTypes.count else {
                throw NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model type count mismatch"])
            }
            
            let modelType = modelTypes[index]
            let result = try await requestAsync(target, modelType: modelType, showLoading: false)
            results.append(result)
        }
        return results
    }
    
    private func showLoadingView() {
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }
    }
    
    private func hiddenLoadingView() {
        SVProgressHUD.dismiss()
    }
}


