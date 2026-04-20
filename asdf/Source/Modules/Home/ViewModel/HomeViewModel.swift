//
//  HomeViewModel.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation

@MainActor
final class HomeViewModel {
    struct AssetSummaryViewData {
        let totalAmount: String
        let walletBalance: String
        let totalAssetValue: String
        let cashManagement: String
        let digitalInvesting: String
        let equity: String
        let cryptocurrency: String
        let updatedAt: String
    }
    
    var onDataUpdated: ((String?, AssetSummaryViewData) -> Void)?
    var onBannerUpdated:  (([HomeBannerModel]) -> Void)?
    var onError: ((String) -> Void)?
    
    func loadHomeData() async {
        do {
            let preferredName = fetchPreferredName()
            async let balances = CommonService.shared.balanceAll(showLoading: true)
            async let banners = HomeService.shared.banner(showLoading: true)
            
            let balanceModel = try await balances
            let bannerList = try await banners
            let summary = makeAssetSummary(from: balanceModel)
            
            onDataUpdated?(preferredName, summary)
            onBannerUpdated?(bannerList)
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    private func fetchPreferredName() -> String? {
        return UserManager.shared.currentUser?.data.responses.preferredName
    }
    
    private func makeAssetSummary(from model: BalancesAllModel) -> AssetSummaryViewData {
        AssetSummaryViewData(
            totalAmount: formatMYR(model.meta.total.value.myr),
            walletBalance: formatMYR(model.meta.cash.value.myr),
            totalAssetValue: formatMYR(model.meta.position.value.myr),
            cashManagement: formatMYR(model.meta.total.kMoney.myr + model.meta.total.kdiSave.myr),
            digitalInvesting: formatMYR(model.meta.total.kdiInvest.myr),
            equity: formatMYR(model.meta.total.rakutenTrade.myr),
            cryptocurrency: formatMYR(model.meta.total.tokenize.myr),
            updatedAt: formatUpdatedAt(model.data.updatedAt)
        )
    }
    
    private func formatMYR(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MYR"
        formatter.currencySymbol = "RM "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "RM 0.00"
    }
    
    private func formatUpdatedAt(_ value: String) -> String {
        return "as of \(value.dateFormat())"
    }
}
