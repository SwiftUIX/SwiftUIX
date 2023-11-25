//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import UIKit

extension AppKitOrUIKitFont {
    public func withSymbolicTraits(
        _ traits: UIFontDescriptor.SymbolicTraits
    ) -> AppKitOrUIKitFont? {
        return fontDescriptor
            .withSymbolicTraits(traits)
            .map({ UIFont(descriptor: $0, size: 0) })
    }
    
    public func addingAttributes(
        _ attributes: [UIFontDescriptor.AttributeName: Any]
    ) -> AppKitOrUIKitFont {
        return .init(
            descriptor: fontDescriptor.addingAttributes(attributes),
            size: 0
        )
    }
    
    public var bold: AppKitOrUIKitFont! {
        return withSymbolicTraits(.traitBold)
    }
    
    public var italic: AppKitOrUIKitFont! {
        return withSymbolicTraits(.traitItalic)
    }
    
    public var monospaced: AppKitOrUIKitFont {
        let settings: [UIFontDescriptor.FeatureKey: Any] = [
            .featureIdentifier: kNumberSpacingType,
            .typeIdentifier: kMonospacedNumbersSelector
        ]
        
        return addingAttributes([.featureSettings: [settings]])
    }
}

#endif
