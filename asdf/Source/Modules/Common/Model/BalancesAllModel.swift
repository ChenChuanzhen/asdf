//
//  BalancesAllModel.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/4/17.
//

import Foundation

struct BalancesAllModel: Codable {
    let data: BalancesAllData
    let meta: BalancesAllMeta
}

struct BalancesAllData: Codable {
    let balances: [BalanceItem]
    let updatedAt: String
}

struct BalanceItem: Codable {
    let id: String
    let type: String
    let attributes: BalanceAttributes
}

struct BalanceAttributes: Codable {
    let product: String
    let value: MoneyValue
}

struct MoneyValue: Codable {
    let currency: String
    let amount: Decimal
}

struct BalancesAllMeta: Codable {
    let total: BalanceTotal
    let cash: BalanceSummary
    let position: BalanceSummary
}

struct BalanceTotal: Codable {
    let value: CurrencyAmounts
    let kdiSave: CurrencyAmounts
    let kdiInvest: CurrencyAmounts
    let tokenize: CurrencyAmounts
    let kMoney: CurrencyAmounts
    let rakutenTrade: CurrencyAmounts
    
    enum CodingKeys: String, CodingKey {
        case value
        case kdiSave = "kdi_save"
        case kdiInvest = "kdi_invest"
        case tokenize
        case kMoney = "k_money"
        case rakutenTrade = "rakuten_trade"
    }
}

struct BalanceSummary: Codable {
    let value: CurrencyAmounts
}

struct CurrencyAmounts: Codable {
    let myr: Decimal
    let usd: Decimal
    let hkd: Decimal
    
    enum CodingKeys: String, CodingKey {
        case myr = "MYR"
        case usd = "USD"
        case hkd = "HKD"
    }
}
