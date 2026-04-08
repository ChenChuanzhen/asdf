import UIKit

extension UIColor {
    
    /// 从十六进制字符串创建 UIColor
    /// - Parameter hex: 十六进制颜色字符串，格式为 "#RRGGBB"
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 从 RGB 值创建 UIColor
    /// - Parameters:
    ///   - red: 红色通道值 (0-255)
    ///   - green: 绿色通道值 (0-255)
    ///   - blue: 蓝色通道值 (0-255)
    ///   - alpha: 透明度 (0-1)
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
}
