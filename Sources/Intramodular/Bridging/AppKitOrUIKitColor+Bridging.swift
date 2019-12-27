//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension Color {
    private func toUIColor0() -> UIColor? {
        switch self {
            case .clear:
                return UIColor.clear
            case .black:
                return UIColor.black
            case .white:
                return UIColor.white
            case .gray:
                return UIColor.gray
            case .red:
                return UIColor.red
            case .green:
                return UIColor.green
            case .blue:
                return UIColor.blue
            case .orange:
                return UIColor.orange
            case .yellow:
                return UIColor.yellow
            case .pink:
                return UIColor.systemPink
            case .purple:
                return UIColor.systemPurple
            case .primary:
                return UIColor.label
            case .secondary:
                return UIColor.secondaryLabel
            default:
                return nil
        }
    }
    
    private func toUIColor1() -> UIColor? {
        let children = Mirror(reflecting: self).children
        let _provider = children.filter { $0.label == "provider" }.first
        
        guard let provider = _provider?.value else {
            return nil
        }
        
        let providerChildren = Mirror(reflecting: provider).children
        let _base = providerChildren.filter { $0.label == "base" }.first
        
        guard let base = _base?.value else {
            return nil
        }
        
        var baseValue: String = ""
        
        dump(base, to: &baseValue)
        
        guard let firstLine = baseValue.split(separator: "\n").first, let hexString = firstLine.split(separator: " ")[1] as Substring? else {
            return nil
        }
        
        return UIColor(hexadecimal: hexString.trimmingCharacters(in: .newlines))
    }
    
    public func toUIColor() -> UIColor? {
        if let color = toUIColor0() {
            return color
        } else if let color = toUIColor1() {
            return color
        } else {
            return nil
        }
    }
}

#endif
