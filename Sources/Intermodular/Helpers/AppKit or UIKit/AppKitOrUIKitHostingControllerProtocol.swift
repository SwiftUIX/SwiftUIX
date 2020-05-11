//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitHostingControllerProtocol: UIViewController {
    func sizeThatFits(in _: CGSize) -> CGSize
}

#elseif os(macOS)

public protocol AppKitOrUIKitHostingControllerProtocol: NSViewController {
    func sizeThatFits(in _: CGSize) -> CGSize
}

#endif

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#elseif os(macOS)

extension NSHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#endif

extension AppKitOrUIKitHostingControllerProtocol {
    func sizeThatFits(
        in size: OptionalDimensions,
        targetSize: OptionalDimensions,
        maximumSize: OptionalDimensions
    ) -> CGSize {
        let fittingSize = CGSize(
            width: size.width ?? .infinity,
            height: size.height ?? .infinity
        ).clamping(to: maximumSize)
        
        var desiredSize = sizeThatFits(in: fittingSize)
        
        switch (desiredSize.width, desiredSize.height)  {
            case (.infinity, .infinity):
                desiredSize = sizeThatFits(in: .init(size, default: .zero))
            case (.infinity, _):
                desiredSize = sizeThatFits(in: CGSize(width: size.width ?? targetSize.width ?? .zero, height: fittingSize.height))
            case (_, .infinity):
                desiredSize = sizeThatFits(in: CGSize(width: fittingSize.width, height: size.height ?? targetSize.height ?? .zero))
            default:
                break
        }
        
        if size.width == nil {
            if let targetWidth = targetSize.width {
                desiredSize.width = targetWidth
            }
        }
        
        if size.height == nil {
            if let targetHeight = targetSize.height {
                desiredSize.height = targetHeight
            }
        }
        
        return desiredSize.clamping(to: maximumSize)
    }
}
