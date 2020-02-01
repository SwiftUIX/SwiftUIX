//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A SwiftUI port of `UIScrollView`.
public struct CocoaScrollView<Content: View>: UIViewRepresentable  {
    public typealias UIViewType = UIScrollView
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        private let base: CocoaScrollView
        
        var isInitialContentAlignmentSet: Bool = false
        
        init(base: CocoaScrollView) {
            self.base = base
        }
        
        @objc public func refreshChanged(_ control: UIRefreshControl) {
            base.onRefresh?()
            
            if let isRefreshing = base.isRefreshing, !isRefreshing {
                control.endRefreshing()
            }
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            base.onPercentContentOffsetChange(scrollView.percentContentOffset)
            scrollView.contentAlignment.map(base.onContentAlignmentChange)
        }
    }
    
    private let content: Content
    private let axes: Axis.Set
    private let showsIndicators: Bool
    
    @Environment(\.initialContentAlignment) var initialContentAlignment
    
    private var alwaysBounceVertical: Bool = false
    private var alwaysBounceHorizontal: Bool = false
    private var isPagingEnabled: Bool = false
    private var isScrollEnabled: Bool = true
    private var isDirectionalLockEnabled: Bool = false
    
    private var onPercentContentOffsetChange: (CGPoint) -> () = { _ in }
    private var onContentAlignmentChange: (Alignment) -> () = { _ in }
    
    private var onRefresh: (() -> Void)?
    private var isRefreshing: Bool?
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIScrollView()
        
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.alwaysBounceVertical = alwaysBounceVertical
        uiView.alwaysBounceHorizontal = alwaysBounceHorizontal
        #if os(iOS) || targetEnvironment(macCatalyst)
        uiView.isPagingEnabled = isPagingEnabled
        #endif
        uiView.isScrollEnabled = isScrollEnabled
        uiView.isDirectionalLockEnabled = isDirectionalLockEnabled
        uiView.showsVerticalScrollIndicator = showsIndicators && axes.contains(.vertical)
        uiView.showsHorizontalScrollIndicator = showsIndicators && axes.contains(.horizontal)
        
        let contentView: UIHostingView<Content>
        
        if let first = uiView.subviews.compactMap({ $0 as? UIHostingView<Content> }).first {
            contentView = first
            contentView.rootView = content
        } else {
            contentView = UIHostingView(rootView: content)
            uiView.addSubview(contentView)
        }
        
        let maximumContentSize: CGSize = .init(
            width: axes.contains(.horizontal) ? CGFloat.greatestFiniteMagnitude : uiView.frame.width,
            height: axes.contains(.vertical) ? CGFloat.greatestFiniteMagnitude : uiView.frame.height
        )
        
        let oldContentSize = contentView.frame.size
        let proposedContentSize = contentView.sizeThatFits(maximumContentSize)
        
        let contentSize = CGSize(
            width: min(proposedContentSize.width, maximumContentSize.width),
            height: min(proposedContentSize.height, maximumContentSize.height)
        )
        
        guard oldContentSize != contentSize else {
            return
        }
        
        contentView.frame.size = contentSize
        uiView.contentSize = contentSize
        
        if !context.coordinator.isInitialContentAlignmentSet {
            if contentSize != .zero && uiView.frame.size != .zero  {
                uiView.setContentAlignment(initialContentAlignment, animated: false)
                
                context.coordinator.isInitialContentAlignmentSet = true
            }
        } else {
            if contentSize != oldContentSize {
                var newContentOffset = uiView.contentOffset
                
                if initialContentAlignment.horizontal == .trailing {
                    newContentOffset.x += contentSize.width - oldContentSize.width
                }
                
                if initialContentAlignment.vertical == .bottom {
                    newContentOffset.y += contentSize.height - oldContentSize.height
                }
                
                if newContentOffset != uiView.contentOffset {
                    uiView.setContentOffset(newContentOffset, animated: false)
                }
            }
        }
        
        if onRefresh != nil {
            let refreshControl: UIRefreshControl
            
            if let _refreshControl = uiView.refreshControl {
                refreshControl = _refreshControl
            } else {
                refreshControl = UIRefreshControl()
                
                refreshControl.addTarget(
                    context.coordinator,
                    action: #selector(Coordinator.refreshChanged),
                    for: .valueChanged
                )
                
                uiView.refreshControl = refreshControl
            }
            
            if let isRefreshing = isRefreshing {
                if isRefreshing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

extension CocoaScrollView {
    public func onPercentContentOffsetChange(_ body: @escaping (CGPoint) -> ()) -> Self {
        then({ $0.onPercentContentOffsetChange = body })
    }
    
    public func onContentAlignmentChange(_ body: @escaping (Alignment) -> ()) -> Self {
        then({ $0.onContentAlignmentChange = body })
    }
}

extension CocoaScrollView {
    public func onRefresh(_ body: @escaping () -> ()) -> Self {
        then({ $0.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.isRefreshing = isRefreshing })
    }
}

#endif
