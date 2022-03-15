//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol _opaque_UIHostingScrollView: UIScrollView {
    func scrollTo(_ edge: Edge)
}

open class UIHostingScrollView<Content: View>: UIScrollView, _opaque_UIHostingScrollView, UIScrollViewDelegate {
    var _isUpdating: Bool = false
    
    private let hostingContentView: UIHostingView<RootViewContainer>
    private var pages: [_CocoaScrollViewPage] = []
    private var isInitialContentAlignmentSet: Bool = false
    private var dragStartContentOffset: CGPoint = .zero
    
    override open var intrinsicContentSize: CGSize {
        guard !contentSize.isAreaZero else {
            return super.intrinsicContentSize
        }
        
        if configuration.axes == .horizontal {
            return .init(
                width: super.intrinsicContentSize.width,
                height: contentSize.height
            )
        } else if configuration.axes == .vertical {
            return .init(
                width: contentSize.width,
                height: super.intrinsicContentSize.height
            )
        } else {
            return super.intrinsicContentSize
        }
    }
    
    public var rootView: Content {
        get {
            hostingContentView.rootView.content
        } set {
            hostingContentView.rootView.content = newValue

            setNeedsLayout()
        }
    }
    
    public var configuration = CocoaScrollViewConfiguration<Content>() {
        didSet {
            configure(with: configuration)
        }
    }
    
    var _isPagingEnabled: Bool {
        #if os(tvOS)
        return false
        #else
        return isPagingEnabled
        #endif
    }
    
    public init(rootView: Content) {
        hostingContentView = UIHostingView(rootView: RootViewContainer(base: nil, content: rootView))
        
        super.init(frame: .zero)
        
        delegate = self
        
        hostingContentView.rootView.base = nil
        
        addSubview(hostingContentView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pageIndex(forContentOffset contentOffset: CGPoint) -> Int? {
        nil
    }
    
    public func contentOffset(forPageIndex pageIndex: Int) -> CGPoint {
        .zero
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }

    private func update() {
        guard !frame.size.isAreaZero else {
            return
        }
        
        let maximumContentSize: CGSize = .init(
            width: configuration.axes.contains(.horizontal)
                ? AppKitOrUIKitView.layoutFittingCompressedSize.width
                : frame.width,
            height: configuration.axes.contains(.vertical)
                ? AppKitOrUIKitView.layoutFittingCompressedSize.height
                : frame.height
        )
        
        let oldContentSize = hostingContentView.frame.size
        let proposedContentSize = hostingContentView.sizeThatFits(maximumContentSize)
        
        let contentSize = CGSize(
            width: min(
                proposedContentSize.width,
                maximumContentSize.width != 0
                    ? maximumContentSize.width
                    : proposedContentSize.width
            ),
            height: min(
                proposedContentSize.height,
                maximumContentSize.height != 0
                    ? maximumContentSize.height
                    : proposedContentSize.height
            )
        )
        
        guard oldContentSize != contentSize else {
            return
        }
        
        hostingContentView.frame.size = contentSize
       
        self.contentSize = contentSize

        hostingContentView.setNeedsDisplay()
        hostingContentView.setNeedsLayout()
        hostingContentView.layoutIfNeeded()
                
        if configuration.axes == .vertical {
            if contentHuggingPriority(for: .horizontal) != .defaultHigh {
                setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
            if contentHuggingPriority(for: .vertical) != .defaultLow {
                setContentHuggingPriority(.defaultLow, for: .horizontal)
            }
        } else if configuration.axes == .horizontal {
            if contentHuggingPriority(for: .horizontal) != .defaultLow {
                setContentHuggingPriority(.defaultLow, for: .horizontal)
            }
            
            if contentHuggingPriority(for: .vertical) != .defaultHigh {
                setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
        }
        
        if configuration.axes == .horizontal || configuration.axes == .vertical {
            invalidateIntrinsicContentSize()
        }
                
        if let initialContentAlignment = configuration.initialContentAlignment {
            if !isInitialContentAlignmentSet {
                if contentSize != .zero && frame.size != .zero {
                    setContentAlignment(initialContentAlignment, animated: false)
                    
                    isInitialContentAlignmentSet = true
                }
            } else {
                if contentSize != oldContentSize {
                    var newContentOffset = contentOffset
                    
                    if contentSize.width >= oldContentSize.width {
                        if initialContentAlignment.horizontal == .trailing {
                            newContentOffset.x += contentSize.width - oldContentSize.width
                        }
                    }
                    
                    if contentSize.height >= oldContentSize.height {
                        if initialContentAlignment.vertical == .bottom {
                            newContentOffset.y += contentSize.height - oldContentSize.height
                        }
                    }
                    
                    if newContentOffset != contentOffset {
                        setContentOffset(newContentOffset, animated: false)
                    }
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate 
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard !_isUpdating else {
            return
        }
        
        dragStartContentOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !_isUpdating else {
            return
        }
        
        if let onOffsetChange = configuration.onOffsetChange {
            onOffsetChange(
                scrollView.contentOffset(forContentType: Content.self)
            )
        }
        
        configuration.contentOffset?.wrappedValue = contentOffset
    }
    
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard !_isUpdating else {
            return
        }
        
        if _isPagingEnabled {
            guard let currentIndex = pageIndex(forContentOffset: dragStartContentOffset) else {
                return
            }
            
            guard var targetIndex = pageIndex(forContentOffset: targetContentOffset.pointee) else {
                return
            }
            
            if targetIndex != currentIndex {
                targetIndex = currentIndex + (targetIndex - currentIndex).signum()
            } else if abs(velocity.x) > 0.25 {
                targetIndex = currentIndex + (velocity.x > 0 ? 1 : 0)
            }
            
            if targetIndex < 0 {
                targetIndex = 0
            } else if targetIndex >= pages.count {
                targetIndex = max(pages.count - 1, 0)
            }
            
            guard targetIndex != currentIndex else {
                return
            }
            
            targetContentOffset.pointee = contentOffset(forPageIndex: targetIndex)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingScrollView {
    struct RootViewContainer: View {
        weak var base: UIHostingScrollView<Content>?
        
        var content: Content
        
        var body: some View {
            PassthroughView {
                if base?._isPagingEnabled ?? false {
                    content.onPreferenceChange(ArrayReducePreferenceKey<_CocoaScrollViewPage>.self, perform: { page in
                        self.base?.pages = page
                    })
                } else {
                    content
                }
            }
        }
    }
}

// MARK: - Conformances -

extension UIHostingScrollView {
    public func scrollTo(_ edge: Edge) {
        let animated = _areAnimationsDisabledGlobally ? false : true
        
        switch edge {
            case .top: do {
                setContentOffset(
                    CGPoint(x: contentOffset.x, y: -contentInset.top),
                    animated: animated
                )
            }
            case .leading: do {
                guard contentSize.width > frame.width else {
                    return
                }

                setContentOffset(
                    CGPoint(x: contentInset.left, y: contentOffset.y),
                    animated: animated
                )
            }
            case .bottom: do {
                setContentOffset(
                    CGPoint(x: contentOffset.x, y: (contentSize.height - bounds.size.height) + contentInset.bottom),
                    animated: animated
                )
            }
            case .trailing: do {
                guard contentSize.width > frame.width else {
                    return
                }
                
                setContentOffset(
                    CGPoint(x: (contentSize.width - bounds.size.width) + contentInset.right, y: contentOffset.y),
                    animated: animated
                )
            }
        }
    }
}

#endif
