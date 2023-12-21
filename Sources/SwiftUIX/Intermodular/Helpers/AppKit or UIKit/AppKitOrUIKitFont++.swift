//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
extension AppKitOrUIKitFont {
    func scaled(
        by ratio: CGFloat
    ) -> AppKitOrUIKitFont {
        let newPointSize = pointSize * ratio
        
        return AppKitOrUIKitFont(
            descriptor: fontDescriptor,
            size: newPointSize
        )
    }
}
#elseif os(macOS)
extension AppKitOrUIKitFont {
    func scaled(
        by ratio: CGFloat
    ) -> NSFont {
        let newPointSize = pointSize * ratio
        
        guard let font = NSFont(
            descriptor: fontDescriptor,
            size: newPointSize
        ) else {
            assertionFailure()
            
            return self
        }
        
        return font
    }
}
#endif
