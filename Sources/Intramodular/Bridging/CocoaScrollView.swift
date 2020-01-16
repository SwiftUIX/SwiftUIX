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
        
        init(base: CocoaScrollView) {
            self.base = base
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.base.contentOffset?.wrappedValue = scrollView.contentOffset.y
            }
        }
    }
    
    private let content: () -> Content
    private let axes: Axis.Set
    private let showsIndicators: Bool
    
    @Environment(\.initialContentAlignment) var initialContentAlignment
    
    private var contentOffset: Binding<CGFloat>? = nil
    
    private var alwaysBounceVertical: Bool = false
    private var alwaysBounceHorizontal: Bool = false
    private var isPagingEnabled: Bool = false
    private var isScrollEnabled: Bool = true
    private var isDirectionalLockEnabled: Bool = false
    
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
        
        if uiView.subviews.isEmpty {
            uiView.addSubview(UIHostingView(rootView: content()))
        } else {
            (uiView.subviews[0] as! UIHostingView<Content>).rootView = content()
        }
        
        let contentView = (uiView.subviews[0] as! UIHostingView<Content>)
        
        uiView.contentSize = contentView.sizeThatFits(
            .init(
                width: axes.contains(.horizontal) ? CGFloat.greatestFiniteMagnitude : uiView.frame.height,
                height: axes.contains(.vertical) ? CGFloat.greatestFiniteMagnitude : uiView.frame.height
            )
        )
        
        contentView.frame.origin.x = uiView.contentSize.width / 2
        contentView.frame.origin.y = uiView.contentSize.height / 2
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#endif
