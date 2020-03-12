//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A SwiftUI port of `UIScrollView`.
public struct CocoaScrollView<Content: View>: UIViewRepresentable  {
    public typealias Offset = ScrollView<Content>.ContentOffset
    public typealias UIViewType = UIScrollView
    
    private let content: Content
    private let axes: Axis.Set
    private let showsIndicators: Bool
    
    @Environment(\.initialContentAlignment) var initialContentAlignment
    @Environment(\.isScrollEnabled) var isScrollEnabled
    
    private var configuration = CocoaScrollViewConfiguration<Content>()
    
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
        let coordinator = context.coordinator
        
        uiView.isScrollEnabled = isScrollEnabled
        uiView.showsVerticalScrollIndicator = showsIndicators && axes.contains(.vertical)
        uiView.showsHorizontalScrollIndicator = showsIndicators && axes.contains(.horizontal)
        
        var configuration = self.configuration
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        configuration.setupRefreshControl = { [weak coordinator] in
            guard let coordinator = coordinator else {
                return
            }
            
            $0.addTarget(
                coordinator,
                action: #selector(Coordinator.refreshChanged),
                for: .valueChanged
            )
        }
        #endif
        
        uiView.configure(with: configuration)
        
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
        
        uiView.frame.size.width = min(uiView.frame.size.width, uiView.contentSize.width)
        uiView.frame.size.height = min(uiView.frame.size.height, uiView.contentSize.height)
        
        if !context.coordinator.isInitialContentAlignmentSet {
            if contentSize != .zero && uiView.frame.size != .zero  {
                uiView.setContentAlignment(initialContentAlignment, animated: false)
                
                context.coordinator.isInitialContentAlignmentSet = true
            }
        } else {
            if contentSize != oldContentSize {
                var newContentOffset = uiView.contentOffset
                
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
                
                if newContentOffset != uiView.contentOffset {
                    uiView.setContentOffset(newContentOffset, animated: false)
                }
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

extension CocoaScrollView {
    public class Coordinator: NSObject, UIScrollViewDelegate {
        private let base: CocoaScrollView
        
        var isInitialContentAlignmentSet: Bool = false
        
        init(base: CocoaScrollView) {
            self.base = base
        }
        
        #if !os(tvOS)
        @objc public func refreshChanged(_ control: UIRefreshControl) {
            control.refreshChanged(with: base.configuration)
        }
        #endif
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            base.configuration.onOffsetChange(
                scrollView.contentOffset(forContentType: Content.self)
            )
        }
    }
}

// MARK: - API -

extension CocoaScrollView {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.configuration.onOffsetChange = body })
    }
}

@available(tvOS, unavailable)
extension CocoaScrollView {
    public func onRefresh(_ body: @escaping () -> ()) -> Self {
        then({ $0.configuration.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.configuration.isRefreshing = isRefreshing })
    }
}

#endif
