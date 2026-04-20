//
//  CommonAPI.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation
import Moya

enum CommonAPI {
    case balanceAll
}

extension CommonAPI: APITargetType {
    
    var path: String {
        switch self {
        case .balanceAll:
            return "/balances/all"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .balanceAll:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .balanceAll:
            return .requestPlain
        }
    }
    
    var shouldShowLoading: Bool {
        switch self {
        case .balanceAll:
            return true
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .balanceAll:
            return true
        }
    }
    
}

