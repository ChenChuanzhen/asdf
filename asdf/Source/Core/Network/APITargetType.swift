import Foundation
import Moya

/// Extended protocol to include loading indicator configuration
protocol APITargetType: TargetType {
    var shouldShowLoading: Bool { get }
    var requiresAuth: Bool { get }
}

extension APITargetType {
    // Default implementation
    var shouldShowLoading: Bool {
        return true
    }
    
    var requiresAuth: Bool {
        return false
    }
}
