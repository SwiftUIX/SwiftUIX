//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension UIFont {
    public func withSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        return fontDescriptor
            .withSymbolicTraits(traits)
            .map({ UIFont(descriptor: $0, size: 0) })
    }
    
    public func addingAttributes(_ attributes: [UIFontDescriptor.AttributeName: Any]) -> UIFont {
        return .init(
            descriptor: fontDescriptor.addingAttributes(attributes),
            size: 0
        )
    }
    
    public var bold: UIFont! {
        return withSymbolicTraits(.traitBold)
    }
    
    public var italic: UIFont! {
        return withSymbolicTraits(.traitItalic)
    }
    
    public var monospaced: UIFont {
        let settings: [UIFontDescriptor.FeatureKey: Any] = [
            .featureIdentifier: kNumberSpacingType,
            .typeIdentifier: kMonospacedNumbersSelector
        ]
        
        return addingAttributes([.featureSettings: [settings]])
    }
}

#endif
