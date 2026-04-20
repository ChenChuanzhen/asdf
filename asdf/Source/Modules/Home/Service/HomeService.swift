//
//  HomeService.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation

final class HomeService {
    static let shared = HomeService()
    
    func banner(showLoading: Bool = true) async throws -> [HomeBannerModel] {
        try await NetworkManager.shared.requestAsync(HomeAPI.banner,
                                                     modelType: [HomeBannerModel].self,
                                                     showLoading: showLoading)
    }
}
