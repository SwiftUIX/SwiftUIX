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

#endif
