//
//  CommonService.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation

final class CommonService {
    
    static let shared = CommonService()
    
    func balanceAll(showLoading: Bool = true) async throws -> BalancesAllModel {
        let balance = try await NetworkManager.shared.requestAsync(CommonAPI.balanceAll, modelType: BalancesAllModel.self, showLoading: showLoading)
        return balance
    }
    
}
