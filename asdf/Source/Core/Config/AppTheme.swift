import UIKit

public struct AppTheme {
    public struct Color {
        // MARK: - 主题色 (Primary Colors)
        public static let primaryBlue = UIColor(hex: "#0B39B0")
        public static let primaryDarkBlue = UIColor(hex: "#0932A0")
        public static let primaryLightBlue = UIColor(hex: "#1B47B9")
        public static let homePrimaryBlue = UIColor(hex: "#1E40AF")
        public static let homeSecondaryBlue = UIColor(hex: "#0D42BA")
        public static let homeGradientCyan = UIColor(hex: "#00DFFF")
        public static let homeGradientIndigo = UIColor(hex: "#00007D")
        public static let bannerDarkBlue = UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0)
        
        // MARK: - 辅色 / 功能色 (Secondary / Functional Colors)
        public static let featureBlue = UIColor(hex: "#3B82F6")
        public static let featureGreen = UIColor(hex: "#10B981")
        public static let featureCardBackground = UIColor(hex: "#F9FAFB")
        public static let partnerBackground = UIColor(hex: "#EBF5FF")
        public static let accentOrange = UIColor(hex: "#FF7F00")
        public static let accentRed = UIColor(hex: "#E54646")
        
        // MARK: - 合作方品牌色 (Partner Colors)
        public static let partnerRed = UIColor(hex: "#E53E3E")
        public static let partnerBlue = UIColor(hex: "#4299E1")
        public static let partnerPurple = UIColor(hex: "#805AD5")
        public static let partnerPink = UIColor(hex: "#D53F8C")
        public static let partnerMaroon = UIColor(hex: "#A31D34")
        public static let partnerRose = UIColor(hex: "#B51C44")
        public static let partnerViolet = UIColor(hex: "#6747F7")
        
        // MARK: - 常用基础色 Alpha 变体 (Alpha Variants)
        public static let whiteAlpha20 = UIColor.white.withAlphaComponent(0.2)
        public static let whiteAlpha60 = UIColor.white.withAlphaComponent(0.6)
        public static let whiteAlpha80 = UIColor.white.withAlphaComponent(0.8)
        public static let whiteAlpha90 = UIColor.white.withAlphaComponent(0.9)
        
        // MARK: - 文本/常用色映射 (Semantic Colors)
        public static let borderDefault = UIColor.systemGray4
        public static let borderLight = UIColor.systemGray5
        public static let borderSoft = UIColor(hex: "#DBDEEA")
        public static let pageIndicator = UIColor.systemGray3
        public static let shadowDefault = UIColor.black
        public static let activeState = UIColor.systemBlue
        public static let textPrimary = UIColor(hex: "#031D45")
        public static let textSecondary = UIColor(hex: "#202123")
        public static let textMuted = UIColor(hex: "#6B7280")
        public static let surfaceMuted = UIColor(hex: "#F5F6F7")
        public static let surfaceCard = UIColor(hex: "#F8FAFD")
    }
}
