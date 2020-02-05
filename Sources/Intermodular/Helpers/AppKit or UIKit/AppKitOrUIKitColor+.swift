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
                return .clear
            case .black:
                return .black
            case .white:
                return .white
            case .gray:
                return .systemGray
            case .red:
                return .systemRed
            case .green:
                return .systemGreen
            case .blue:
                return .systemBlue
            case .orange:
                return .systemOrange
            case .yellow:
                return .systemYellow
            case .pink:
                return .systemPink
            case .primary:
                return .label // FIXME?
            case .secondary:
                return .secondaryLabel // FIXME?
            default:
                return nil
        }
    }
    
    private func toUIColor1() -> UIColor? {
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
    
    private func toUIColor2() -> UIColor? {
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
        nil
            ?? toUIColor0()
            ?? toUIColor1()
            ?? toUIColor2()
    }
}

#endif
