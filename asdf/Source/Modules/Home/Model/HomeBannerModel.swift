//
//  HomeBannerModel.swift
//  asdf
//
//  Created by Codex on 2026/4/17.
//

import Foundation

struct HomeBannerModel: Codable {
    let id: Int
    let title: String
    let imageUrl: String
    let targetUrl: String
    let menuOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl = "image_url"
        case targetUrl = "target_url"
        case menuOrder = "menu_order"
    }
}
