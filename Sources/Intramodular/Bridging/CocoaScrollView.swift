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
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            base.onPercentContentOffsetChange(scrollView.percentContentOffset)
            scrollView.contentAlignment.map(base.onContentAlignmentChange)
        }
    }
    
    private let content: () -> Content
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
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
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
            contentView.rootView = content()
        } else {
            contentView = UIHostingView(rootView: content())
            
            uiView.addSubview(contentView)
        }
        
        let contentSize = contentView.sizeThatFits(
            .init(
                width: axes.contains(.horizontal) ? CGFloat.greatestFiniteMagnitude : uiView.frame.width,
                height: axes.contains(.vertical) ? CGFloat.greatestFiniteMagnitude : uiView.frame.height
            )
        )
        
        contentView.frame.size = contentSize
        uiView.contentSize = contentSize
        
        if !context.coordinator.isInitialContentAlignmentSet {
            if contentSize != .zero && uiView.frame.size != .zero  {
                uiView.setContentAlignment(initialContentAlignment, animated: false)
                
                context.coordinator.isInitialContentAlignmentSet = true
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

extension CocoaScrollView {
    public func onPercentContentOffsetChange(_ body: @escaping (CGPoint) -> ()) -> CocoaScrollView {
        then {
            $0.onPercentContentOffsetChange = body
        }
    }
    
    public func onContentAlignmentChange(_ body: @escaping (Alignment) -> ()) -> CocoaScrollView {
        then {
            $0.onContentAlignmentChange = body
        }
    }
}

#endif
