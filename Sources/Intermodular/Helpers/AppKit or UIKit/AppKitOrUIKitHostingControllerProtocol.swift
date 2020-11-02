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

extension UIHostingController {
    func _disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
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
            width: size.width ?? .infinity,
            height: size.height ?? .infinity
        )
        .clamping(to: maximumSize)
        
        var result = sizeThatFits(in: fittingSize)
        
        switch (result.width, result.height)  {
            case (.infinity, .infinity):
                result = sizeThatFits(in: .init(size, default: .zero))
            case (.infinity, _):
                result = sizeThatFits(in: CGSize(width: size.width ?? targetSize.width ?? .zero, height: fittingSize.height))
            case (_, .infinity):
                result = sizeThatFits(in: CGSize(width: fittingSize.width, height: size.height ?? targetSize.height ?? .zero))
            case (.zero, 1...):
                result = sizeThatFits(in: CGSize(width: UIView.layoutFittingExpandedSize.width, height: fittingSize.height))
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
