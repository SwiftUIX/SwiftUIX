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
    public func sizeThatFits(_ sizeProposal: AppKitOrUIKitLayoutSizeProposal) -> CGSize {
        let targetSize = sizeProposal.appKitOrUIKitTargetSize
        let fittingSize = sizeProposal.appKitOrUIKitFittingSize
        
        guard sizeProposal.allowsSelfSizing else {
            return targetSize
        }
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        #elseif os(macOS)
        view.layout()
        #endif
        
        var result = sizeThatFits(in: fittingSize)
        
        switch (result.width, result.height)  {
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, AppKitOrUIKitView.layoutFittingExpandedSize.height), (.greatestFiniteMagnitude, .greatestFiniteMagnitude):
                result = sizeThatFits(in: targetSize.clamping(to: sizeProposal.maximumSize))
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, _), (.greatestFiniteMagnitude, _):
                result = sizeThatFits(in: CGSize(width: targetSize.clamping(to: sizeProposal.maximumSize).width, height: fittingSize.height))
            case (_, AppKitOrUIKitView.layoutFittingExpandedSize.height), (_, .greatestFiniteMagnitude):
                result = sizeThatFits(in: CGSize(width: fittingSize.width, height: targetSize.clamping(to: sizeProposal.maximumSize).height))
            case (.zero, 1...): do {
                result = sizeThatFits(in: CGSize(width: AppKitOrUIKitView.layoutFittingExpandedSize.width, height: fittingSize.height))
            }
            case (1..., .zero): do {
                result = sizeThatFits(in: CGSize(width: fittingSize.width, height: AppKitOrUIKitView.layoutFittingExpandedSize.width))
            }
            default:
                break
        }
        
        result = CGSize(
            width: sizeProposal.horizontalFittingPriority == .required
                ? targetSize.width
                : result.width,
            height: sizeProposal.verticalFittingPriority == .required
                ? targetSize.height
                : result.height
        )
        
        return result.clamping(to: sizeProposal.maximumSize)
    }
    
    public func sizeThatFits(
        in size: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) -> CGSize {
        return sizeThatFits(
            .init(
                targetSize: .init(size),
                horizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority:  verticalFittingPriority
            )
        )
    }
}

// MARK: - Auxiliary Implementation -

public struct AppKitOrUIKitLayoutSizeProposal {
    var targetSize: OptionalDimensions = nil
    var maximumSize: OptionalDimensions = nil
    var horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    var verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    
    var allowsSelfSizing: Bool {
        if horizontalFittingPriority == .required && verticalFittingPriority == .required {
            return false
        } else {
            return true
        }
    }
    
    var appKitOrUIKitTargetSize: CGSize {
        let width = targetSize.width ?? ((horizontalFittingPriority ?? .defaultLow) != .required ? AppKitOrUIKitView.layoutFittingExpandedSize.width : AppKitOrUIKitView.layoutFittingExpandedSize.width)
        let height = targetSize.height ?? ((verticalFittingPriority ?? .defaultLow) != .required ? AppKitOrUIKitView.layoutFittingExpandedSize.height : AppKitOrUIKitView.layoutFittingExpandedSize.height)
        
        return .init(width: width, height: height)
    }
    
    var appKitOrUIKitFittingSize: CGSize {
        let width = horizontalFittingPriority == .required
            ? targetSize.clamping(to: maximumSize).width ?? AppKitOrUIKitView.layoutFittingCompressedSize.width
            : (maximumSize.width ?? AppKitOrUIKitView.layoutFittingExpandedSize.width)
        
        let height = verticalFittingPriority == .required
            ? targetSize.clamping(to: maximumSize).height ?? AppKitOrUIKitView.layoutFittingCompressedSize.height
            : (maximumSize.height ?? AppKitOrUIKitView.layoutFittingExpandedSize.height)
        
        return CGSize(width: width, height: height)
    }
}

#endif
