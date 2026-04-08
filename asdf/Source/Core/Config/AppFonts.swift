//
//  AppFonts.swift
//  asdf
//
//  Created by 咸鱼悠游 on 2026/3/29.
//

import Foundation
import UIKit

extension UIFont {
    
    static func dmSansFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "DMSans-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        case .semibold:
            return UIFont(name: "DMSans-SemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
        case .medium:
            return UIFont(name: "DMSans-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
        default:
            return UIFont(name: "DMSans-Regular", size: size) ?? .systemFont(ofSize: size, weight: weight)
        }
    }
    
    static func robotoFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "Roboto-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        case .medium:
            return UIFont(name: "Roboto-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
        default:
            return UIFont(name: "Roboto-Regular", size: size) ?? .systemFont(ofSize: size, weight: weight)
        }
    }
}
