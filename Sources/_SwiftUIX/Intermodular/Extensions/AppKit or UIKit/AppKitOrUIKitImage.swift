//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitImage {
    public var _SwiftUIX_cgImage: CGImage? {
        cgImage
    }
}
#endif

#if canImport(CoreVideo)
import CoreVideo

extension AppKitOrUIKitImage {
    public func _SwiftUIX_toPixelBuffer() -> CVPixelBuffer? {
        _SwiftUIX_cgImage?._SwiftUIX_toPixelBuffer()
    }
}
#endif
