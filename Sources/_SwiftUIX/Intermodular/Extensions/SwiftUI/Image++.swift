//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Image {
#if os(macOS)
    public typealias _AppKitOrUIKitType = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
    public typealias _AppKitOrUIKitType = UIImage
#endif
    
    public func _toAppKitOrUIKitImage(
        in environment: EnvironmentValues
    ) -> _AppKitOrUIKitType? {
        _SwiftUI_ImageProvider(for: self)?.resolved(in: environment)
    }
}
