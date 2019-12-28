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
    
    var contentOffset: Binding<CGFloat>?
    
    private var alwaysBounceVertical: Bool = false
    private var alwaysBounceHorizontal: Bool = false
    private var isPagingEnabled: Bool = false
    private var isScrollEnabled: Bool = true
    private var isDirectionalLockEnabled: Bool = false
    private var showsVerticalScrollIndicator: Bool = true
    private var showsHorizontalScrollIndicator: Bool = true
    
    public init(
        contentOffset: Binding<CGFloat>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.contentOffset = contentOffset
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
        uiView.isPagingEnabled = isPagingEnabled
        uiView.isScrollEnabled = isScrollEnabled
        uiView.isDirectionalLockEnabled = isDirectionalLockEnabled
        uiView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        uiView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        
        if uiView.subviews.isEmpty {
            uiView.addSubview(UIHostingView(rootView: content()))
        } else {
            (uiView.subviews[0] as! UIHostingView<Content>).rootView = content()
        }
        
        let contentView = (uiView.subviews[0] as! UIHostingView<Content>)
        
        contentView.frame.origin.x = uiView.contentSize.width / 2
        contentView.frame.origin.y = uiView.contentSize.height / 2
        
        uiView.contentSize = contentView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#endif
