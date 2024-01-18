//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A zero-size view for when `EmptyView` just doesn't work.
fileprivate struct _ZeroSizeView: AppKitOrUIKitViewRepresentable {
    final class AppKitOrUIKitViewType: AppKitOrUIKitView {
        public override var intrinsicContentSize: CGSize {
            .zero
        }
        
        #if os(macOS)
        override var acceptsFirstResponder: Bool {
            false
        }

        override var fittingSize: NSSize {
            .zero
        }

        override var needsUpdateConstraints: Bool {
            get {
                false
            } set {
                if super.needsUpdateConstraints {
                    super.needsUpdateConstraints = false
                }
            }
        }
        #endif
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        
        override func invalidateIntrinsicContentSize() {
            
        }
        
        #if os(iOS)
        override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
            .zero
        }
        
        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            .zero
        }
        #elseif os(macOS)
        override func updateConstraintsForSubtreeIfNeeded() {
            
        }
        #endif
    }
    
    init() {
        
    }
    
    func makeAppKitOrUIKitView(
        context: Context
    ) -> AppKitOrUIKitViewType {
        let view = AppKitOrUIKitViewType()
        
        #if os(iOS)
        view.isAccessibilityElement = false
        view.isHidden = true
        view.isOpaque = true
        view.isUserInteractionEnabled = false
        
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        #endif
        
        view.frame.size = .zero
        
        return view
    }
    
    func updateAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        view.frame.size = .zero
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        .zero
    }
}

@frozen
public struct ZeroSizeView: View {
    public var body: some View {
        _ZeroSizeView()
            .frame(width: 0, height: 0)
            .accessibility(hidden: true)
            .allowsHitTesting(false)
    }
    
    public init() {
        
    }
}

#else

/// A zero-size view for when `EmptyView` just doesn't work.
@frozen
public struct ZeroSizeView: View {
    public var body: some View {
        Color.almostClear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .accessibility(hidden: true)
    }
    
    public init() {
        
    }
}

#endif
