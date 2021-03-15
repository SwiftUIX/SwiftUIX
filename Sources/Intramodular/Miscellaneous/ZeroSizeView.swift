//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A zero-size view for when `EmptyView` just doesn't work.
public struct ZeroSizeView: AppKitOrUIKitViewRepresentable {
    public final class AppKitOrUIKitViewType: AppKitOrUIKitView {
        public override var intrinsicContentSize: CGSize {
            .zero
        }
        
        public override init(frame: CGRect) {
            super.init(frame: .zero)
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        #if os(iOS)
        public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
            .zero
        }
        
        public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            .zero
        }
        #endif
    }
    
    @inlinable
    public init() {
        
    }
    
    @inlinable
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let view = AppKitOrUIKitViewType()
        
        #if os(iOS)
        view.isAccessibilityElement = false
        view.isHidden = true
        view.isOpaque = true
        view.isUserInteractionEnabled = false
        #endif
        
        view.frame.size = .zero
        
        return view
    }
    
    @inlinable
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.frame.size = .zero
    }
}

#else

/// A zero-size view for when `EmptyView` just doesn't work.
public struct ZeroSizeView: View {
    @inlinable
    public var body: some View {
        Color.almostClear.frameZeroClipped()
    }
    
    @inlinable
    public init() {
        
    }
}

#endif
