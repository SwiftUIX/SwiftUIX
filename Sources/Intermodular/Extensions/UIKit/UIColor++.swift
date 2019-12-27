//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension UIColor {
    convenience init?(hexadecimal: String, alpha: CGFloat = 1.0) {
        var hexadecimal = hexadecimal
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .uppercased()
        
        if hexadecimal.hasPrefix("#") {
            hexadecimal = String(hexadecimal.dropFirst())
        }
        
        guard hexadecimal.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        
        Scanner(string: hexadecimal).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

#endif
