//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct _UIHostingScrollViewRootView<Content: View>: View {
    weak var base: UIHostingScrollView<Content>?
    
    var content: Content
    
    var body: some View {
        Group {
            if base?.isPagingEnabled ?? false {
                content.onPreferenceChange(ArrayReducePreferenceKey<_CocoaScrollViewPage>.self, perform: { page in
                    self.base?.pages = page
                })
            } else {
                content
            }
        }
    }
}

open class UIHostingScrollView<Content: View>: UIScrollView, UIScrollViewDelegate {
    let hostingContentView: UIHostingView<_UIHostingScrollViewRootView<Content>>
    
    public var rootView: Content {
        get {
            hostingContentView.rootView.content
        } set {
            hostingContentView.rootView.content = newValue
            
            update()
        }
    }
    
    var pages: [_CocoaScrollViewPage] = []
    
    private var isInitialContentAlignmentSet: Bool = false
    private var dragStartContentOffset: CGPoint = .zero
    
    public var configuration = CocoaScrollViewConfiguration<Content>() {
        didSet {
            #if os(iOS) || targetEnvironment(macCatalyst)
            configuration.setupRefreshControl = { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                $0.addTarget(
                    self,
                    action: #selector(self.refreshChanged),
                    for: .valueChanged
                )
            }
            #endif
            
            configure(with: configuration)
        }
    }
    
    public init(rootView: Content) {
        hostingContentView = UIHostingView(rootView: _UIHostingScrollViewRootView(base: nil, content: rootView))
        
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
    
    func update() {
        let maximumContentSize: CGSize = .init(
            width: configuration.axes.contains(.horizontal)
                ? 0
                : frame.width,
            height: configuration.axes.contains(.vertical)
                ? 0
                : frame.height
        )
        
        let oldContentSize = hostingContentView.frame.size
        let proposedContentSize = hostingContentView.sizeThatFits(maximumContentSize)
                
        let contentSize = CGSize(
            width: min(proposedContentSize.width, maximumContentSize.width != 0 ? maximumContentSize.width : proposedContentSize.width),
            height: min(proposedContentSize.height, maximumContentSize.height != 0 ? maximumContentSize.height : proposedContentSize.height)
        )
        
        guard oldContentSize != contentSize else {
            return
        }
        
        hostingContentView.frame.size = contentSize
        
        self.contentSize = contentSize
        
        frame.size.width = min(frame.size.width, contentSize.width)
        frame.size.height = min(frame.size.height, contentSize.height)
        
        if !isInitialContentAlignmentSet {
            if contentSize != .zero && frame.size != .zero {
                setContentAlignment(configuration.initialContentAlignment, animated: false)
                
                isInitialContentAlignmentSet = true
            }
        } else {
            if contentSize != oldContentSize {
                var newContentOffset = contentOffset
                
                if contentSize.width >= oldContentSize.width {
                    if configuration.initialContentAlignment.horizontal == .trailing {
                        newContentOffset.x += contentSize.width - oldContentSize.width
                    }
                }
                
                if contentSize.height >= oldContentSize.height {
                    if configuration.initialContentAlignment.vertical == .bottom {
                        newContentOffset.y += contentSize.height - oldContentSize.height
                    }
                }
                
                if newContentOffset != contentOffset {
                    setContentOffset(newContentOffset, animated: false)
                }
            }
        }
    }
    
    #if !os(tvOS)
    @objc public func refreshChanged(_ control: UIRefreshControl) {
        control.refreshChanged(with: configuration)
    }
    #endif
    
    // MARK: - UIScrollViewDelegate -
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStartContentOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configuration.onOffsetChange(
            scrollView.contentOffset(forContentType: Content.self)
        )
    }
    
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
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
