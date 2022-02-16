//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_AppKitOrUIKitHostingControllerProtocol {
    func _fixSafeAreaInsets()
}

@MainActor
public protocol AppKitOrUIKitHostingControllerProtocol: _opaque_AppKitOrUIKitHostingControllerProtocol, AppKitOrUIKitViewController {
    @MainActor
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

@MainActor
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

        var result: CGSize = sizeThatFits(in: fittingSize)

        switch (result.width, result.height)  {
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, AppKitOrUIKitView.layoutFittingExpandedSize.height), (.greatestFiniteMagnitude, .greatestFiniteMagnitude), (.infinity, .infinity):
                result = sizeThatFits(in: targetSize.clamped(to: sizeProposal.maximumSize))
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, _), (.greatestFiniteMagnitude, _), (.infinity, _):
                if !targetSize.width.isZero {
                    result = sizeThatFits(in: CGSize(width: targetSize.clamped(to: sizeProposal.maximumSize).width, height: fittingSize.height))
                }
            case (_, AppKitOrUIKitView.layoutFittingExpandedSize.height), (_, .greatestFiniteMagnitude), (_, .infinity):
                if !targetSize.height.isZero {
                    result = sizeThatFits(in: CGSize(width: fittingSize.width, height: targetSize.clamped(to: sizeProposal.maximumSize).height))
                }
            case (.zero, 1...): do {
                result = sizeThatFits(in: CGSize(width: AppKitOrUIKitView.layoutFittingExpandedSize.width, height: fittingSize.height))
            }
            case (1..., .zero): do {
                result = sizeThatFits(in: CGSize(width: fittingSize.width, height: AppKitOrUIKitView.layoutFittingExpandedSize.width))
            }
            case (.zero, .zero): do {
                result = sizeThatFits(in: AppKitOrUIKitView.layoutFittingExpandedSize)
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

        if result.width.isZero && !result.height.isZero {
            result = .init(width: 1, height: result.height)
        } else if !result.width.isZero && result.height.isZero {
            result = .init(width: result.width, height: 1)
        }

        return result.clamped(to: sizeProposal.maximumSize)
    }

    public func sizeThatFits(
        in size: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) -> CGSize {
        sizeThatFits(
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
    
    public init(
        targetSize: OptionalDimensions = nil,
        maximumSize: OptionalDimensions = nil,
        horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) {
        self.targetSize = targetSize
        self.maximumSize = maximumSize
        self.horizontalFittingPriority = horizontalFittingPriority
        self.verticalFittingPriority = verticalFittingPriority
    }
    
    public init(
        targetSize: CGSize,
        maximumSize: OptionalDimensions = nil,
        horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) {
        self.init(
            targetSize: .init(targetSize),
            maximumSize: maximumSize,
            horizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
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
            ? targetSize.clamped(to: maximumSize).width ?? AppKitOrUIKitView.layoutFittingCompressedSize.width
            : (maximumSize.width ?? AppKitOrUIKitView.layoutFittingExpandedSize.width)
        
        let height = verticalFittingPriority == .required
            ? targetSize.clamped(to: maximumSize).height ?? AppKitOrUIKitView.layoutFittingCompressedSize.height
            : (maximumSize.height ?? AppKitOrUIKitView.layoutFittingExpandedSize.height)
        
        return CGSize(width: width, height: height)
    }
}

#endif
