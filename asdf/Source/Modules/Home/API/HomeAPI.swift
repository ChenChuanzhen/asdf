//
//  HomeAPI.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation
import Moya

enum HomeAPI {
    case banner
}

extension HomeAPI: APITargetType {
    
    var path: String {
        switch self {
        case .banner:
            return "/v3/market/banners"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .banner:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .banner:
            return  .requestPlain
        }
    }
    
}
