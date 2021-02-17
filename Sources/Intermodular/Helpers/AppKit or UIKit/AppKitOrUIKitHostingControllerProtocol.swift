//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitHostingControllerProtocol: AppKitOrUIKitViewController {
    func sizeThatFits(in _: CGSize) -> CGSize
}

#endif

// MARK: - Conformances -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#elseif os(macOS)

extension NSHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AppKitOrUIKitHostingControllerProtocol {
    func _fixed_sizeThatFits(
        in size: OptionalDimensions,
        targetSize: OptionalDimensions = nil,
        maximumSize: OptionalDimensions = nil
    ) -> CGSize {
        let fittingSize = CGSize(
            width: size.width ?? .greatestFiniteMagnitude,
            height: size.height ?? .greatestFiniteMagnitude
        )
        .clamping(to: maximumSize)
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        #elseif os(macOS)
        view.layout()
        #endif
        
        var result = sizeThatFits(in: fittingSize)
        
        switch (result.width, result.height)  {
            case (.greatestFiniteMagnitude, .greatestFiniteMagnitude):
                result = sizeThatFits(in: .init(size, default: .zero))
            case (.greatestFiniteMagnitude, _):
                result = sizeThatFits(in: CGSize(width: size.width ?? targetSize.width ?? .zero, height: fittingSize.height))
            case (_, .greatestFiniteMagnitude):
                result = sizeThatFits(in: CGSize(width: fittingSize.width, height: size.height ?? targetSize.height ?? .zero))
            case (.zero, 1...): do {
                #if os(iOS) || os(tvOS)
                result = sizeThatFits(in: CGSize(width: UIView.layoutFittingExpandedSize.width, height: fittingSize.height))
                #endif
            }
            default:
                break
        }
        
        if size.width == nil {
            if let targetWidth = targetSize.width {
                result.width = targetWidth
            }
        }
        
        if size.height == nil {
            if let targetHeight = targetSize.height {
                result.height = targetHeight
            }
        }
        
        return result.clamping(to: maximumSize)
    }
    
    func _fixed_sizeThatFits(in size: CGSize) -> CGSize {
        _fixed_sizeThatFits(in: .init(size))
    }
}

#endif
