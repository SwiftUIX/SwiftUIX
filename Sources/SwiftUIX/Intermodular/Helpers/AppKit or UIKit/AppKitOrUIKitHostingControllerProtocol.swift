//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

public protocol _opaque_AppKitOrUIKitHostingControllerProtocol {
    func _disableSafeAreaInsets()
}

@MainActor
public protocol AppKitOrUIKitHostingControllerProtocol: _opaque_AppKitOrUIKitHostingControllerProtocol, AppKitOrUIKitViewController {
    @MainActor
    func sizeThatFits(in _: CGSize) -> CGSize
}

#endif

// MARK: - Conformances

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension UIHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#elseif os(macOS)

extension NSHostingController: AppKitOrUIKitHostingControllerProtocol {
    
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@MainActor
extension AppKitOrUIKitHostingControllerProtocol {
    public func sizeThatFits(
        _ sizeProposal: AppKitOrUIKitLayoutSizeProposal,
        layoutImmediately: Bool
    ) -> CGSize {
        let targetSize = sizeProposal._targetAppKitOrUIKitSize
        let fitSize = sizeProposal._fitAppKitOrUIKitSize

        guard !sizeProposal.fixedSize else {
            var result = targetSize
            
            if layoutImmediately {
                view._UIKit_only_sizeToFit()
            }
            
            let intrinsicContentSize = view.intrinsicContentSize
            
            if !intrinsicContentSize.width._isInvalidForIntrinsicContentSize {
                result.width = intrinsicContentSize.width
            }
            
            if !intrinsicContentSize.height._isInvalidForIntrinsicContentSize {
                result.height = intrinsicContentSize.height
            }
            
            return result
        }

        #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
        if layoutImmediately {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        #elseif os(macOS)
        if layoutImmediately {
            view.layout()
        }
        #endif

        var result: CGSize = _SwiftUIX_sizeThatFits(in: fitSize)

        switch (result.width, result.height)  {
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, AppKitOrUIKitView.layoutFittingExpandedSize.height), (.greatestFiniteMagnitude, .greatestFiniteMagnitude), (.infinity, .infinity):
                result = _SwiftUIX_sizeThatFits(
                    in: targetSize.clamped(to: sizeProposal.size.maximum)
                )
            case (AppKitOrUIKitView.layoutFittingExpandedSize.width, _), (.greatestFiniteMagnitude, _), (.infinity, _):
                if !targetSize.width.isZero {
                    result = _SwiftUIX_sizeThatFits(
                        in: CGSize(
                            width: targetSize.clamped(to: sizeProposal.size.maximum).width,
                            height: fitSize.height
                        )
                    )
                }
            case (_, AppKitOrUIKitView.layoutFittingExpandedSize.height), (_, .greatestFiniteMagnitude), (_, .infinity):
                if !targetSize.height.isZero {
                    result = _SwiftUIX_sizeThatFits(
                        in: CGSize(
                            width: fitSize.width,
                            height: targetSize.clamped(to: sizeProposal.size.maximum).height
                        )
                    )
                }
            case (.zero, 1...): do {
                result = _SwiftUIX_sizeThatFits(
                    in: CGSize(
                        width: AppKitOrUIKitView.layoutFittingExpandedSize.width,
                        height: fitSize.height
                    )
                )
            }
            case (1..., .zero): do {
                result = _SwiftUIX_sizeThatFits(
                    in: CGSize(
                        width: fitSize.width,
                        height: AppKitOrUIKitView.layoutFittingExpandedSize.width
                    )
                )
            }
            case (.zero, .zero): do {
                result = _SwiftUIX_sizeThatFits(
                    in: AppKitOrUIKitView.layoutFittingExpandedSize
                )
            }
            default:
                break
        }

        result = CGSize(
            width: sizeProposal.fit.horizontal == .required
                ? targetSize.width
                : result.width,
            height: sizeProposal.fit.vertical == .required
                ? targetSize.height
                : result.height
        )

        if result.width.isZero && !result.height.isZero {
            result = .init(width: 1, height: result.height)
        } else if !result.width.isZero && result.height.isZero {
            result = .init(width: result.width, height: 1)
        }

        return result.clamped(to: sizeProposal.size.maximum)
    }
    
    private func _SwiftUIX_sizeThatFits(in size: CGSize) -> CGSize {
        if let _self = (self as? CocoaViewController) {
            return _self._SwiftUIX_sizeThatFits(in: size)
        } else {
            return sizeThatFits(in: size)
        }
    }

    public func sizeThatFits(
        _ proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize {
        self.sizeThatFits(proposal, layoutImmediately: true)
    }
    
    public func sizeThatFits(
        in size: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) -> CGSize {
        sizeThatFits(
            .init(
                targetSize: size,
                horizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority:  verticalFittingPriority
            )
        )
    }
}

// MARK: - Auxiliary

public struct AppKitOrUIKitLayoutSizeProposal: Hashable {
    public struct _SizingConstraints: Hashable {
        public fileprivate(set) var minimum: OptionalDimensions
        public fileprivate(set) var target: OptionalDimensions
        public fileprivate(set) var maximum: OptionalDimensions
        
        public init(
            minimum: OptionalDimensions,
            target: OptionalDimensions,
            maximum: OptionalDimensions
        ) {
            self.minimum = minimum
            self.target = target
            self.maximum = maximum
        }
        
        public init(
            target: OptionalDimensions,
            maximum: OptionalDimensions
        ) {
            self.init(minimum: nil, target: target, maximum: maximum)
        }
    }
    
    public struct _Fit: Hashable {
        public let horizontal: AppKitOrUIKitLayoutPriority?
        public let vertical: AppKitOrUIKitLayoutPriority?
        
        public init(horizontal: AppKitOrUIKitLayoutPriority?, vertical: AppKitOrUIKitLayoutPriority?) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
    
    @usableFromInline
    fileprivate(set) var size: _SizingConstraints
    @usableFromInline
    fileprivate(set) var fit: _Fit
    
    var fixedSize: Bool {
        if fit.horizontal == .required && fit.vertical == .required {
            return true
        } else {
            return false
        }
    }
}

extension AppKitOrUIKitLayoutSizeProposal {
    @_transparent
    public var targetWidth: CGFloat? {
        size.target.width
    }
    
    @_transparent
    public var targetHeight: CGFloat? {
        size.target.height
    }
    
    @_transparent
    public var targetArea: CGFloat? {
        guard let targetWidth, let targetHeight else {
            return nil
        }
        
        return targetWidth * targetHeight
    }

    public var maxWidth: CGFloat? {
        size.maximum.width ?? size.target.width
    }
    
    public var maxHeight: CGFloat? {
        size.maximum.height ?? size.target.height
    }
}

extension AppKitOrUIKitLayoutSizeProposal {
    public func replacingUnspecifiedDimensions(
        by replacement: CGSize
    ) -> Self {
        var result = self
        
        result.size.target = self.size.target.replacingUnspecifiedDimensions()
        
        return result
    }
}

extension OptionalDimensions {
    public func replacingUnspecifiedDimensions(
        by replacement: CGSize = CGSize(width: 10, height: 10)
    ) -> Self {
        var result = self
        
        result.width = result.width ?? replacement.width
        result.height = result.height ?? replacement.height
        
        return result
    }
    
    @_disfavoredOverload
    public func replacingUnspecifiedDimensions(
        by replacement: CGSize = CGSize(width: 10, height: 10)
    ) -> CGSize {
        CGSize(
            width: width ?? replacement.width,
            height: height ?? replacement.height
        )
    }
    
    public func toCGSize() -> CGSize? {
        guard let width, let height else {
            return nil
        }
        
        return CGSize(width: width, height: height)
    }
}

extension AppKitOrUIKitLayoutSizeProposal {
    public init(
        size: (target: OptionalDimensions, max: OptionalDimensions),
        fit: _Fit
    ) {
        self.size = .init(minimum: nil, target: size.target, maximum: size.max)
        self.fit = fit
    }

    public init(
        targetSize: OptionalDimensions,
        maximumSize: OptionalDimensions,
        horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) {
        self.size = .init(minimum: nil, target: targetSize, maximum: maximumSize)
        self.fit = .init(horizontal: horizontalFittingPriority, vertical: verticalFittingPriority)
    }
    
    public init<T: _CustomOptionalDimensionsConvertible>(
        targetSize: T,
        horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) {
        self.init(
            targetSize: .init(targetSize),
            maximumSize: nil,
            horizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    public init<T: _CustomOptionalDimensionsConvertible>(
        _ size: T,
        fixedSize: (horizontal: Bool, vertical: Bool)? = nil
    ) {
        self.init(
            targetSize: size,
            horizontalFittingPriority: fixedSize.map({ $0.horizontal ? .required : .defaultLow }),
            verticalFittingPriority: fixedSize.map({ $0.vertical ? .required : .defaultLow })
        )
    }
    
    public init(width: CGFloat?, height: CGFloat?) {
        self.init(OptionalDimensions(width: width, height: height), fixedSize: nil)
    }
    
    public init(
        fixedSize: (horizontal: Bool, vertical: Bool)
    ) {
        self.init(OptionalDimensions(), fixedSize: fixedSize)
    }

    public init<T0: _CustomOptionalDimensionsConvertible, T1: _CustomOptionalDimensionsConvertible>(
        targetSize: T0,
        maximumSize: T1,
        horizontalFittingPriority: AppKitOrUIKitLayoutPriority? = nil,
        verticalFittingPriority: AppKitOrUIKitLayoutPriority? = nil
    ) {
        self.init(
            targetSize: .init(targetSize),
            maximumSize: .init(maximumSize),
            horizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
}

extension AppKitOrUIKitLayoutSizeProposal {
    var _targetAppKitOrUIKitSize: CGSize {
        let width = size.target.width ?? ((fit.horizontal ?? .defaultLow) != .required ? AppKitOrUIKitView.layoutFittingExpandedSize.width : AppKitOrUIKitView.layoutFittingCompressedSize.width)
        let height = size.target.height ?? ((fit.vertical ?? .defaultLow) != .required ? AppKitOrUIKitView.layoutFittingExpandedSize.height : AppKitOrUIKitView.layoutFittingCompressedSize.height)
        
        return CGSize(width: width, height: height)
    }
    
    var _fitAppKitOrUIKitSize: CGSize {
        let targetWidth = size.target.clamped(to: size.maximum).width
        let targetHeight = size.target.clamped(to: size.maximum).height

        let width = fit.horizontal == .required
            ? (targetWidth ?? AppKitOrUIKitView.layoutFittingCompressedSize.width)
            : (size.maximum.width ?? AppKitOrUIKitView.layoutFittingExpandedSize.width)
        
        let height = fit.vertical == .required
            ? (targetHeight ?? AppKitOrUIKitView.layoutFittingCompressedSize.height)
            : (size.maximum.height ?? AppKitOrUIKitView.layoutFittingExpandedSize.height)
        
        return CGSize(width: width, height: height)
    }
}

extension AppKitOrUIKitLayoutSizeProposal: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(
            targetSize: nil,
            maximumSize: nil,
            horizontalFittingPriority: nil,
            verticalFittingPriority: nil
        )
    }
}

#endif
