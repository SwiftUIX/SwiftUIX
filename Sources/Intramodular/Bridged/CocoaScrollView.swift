//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A SwiftUI port of `UIScrollView`.
public struct CocoaScrollView<Content: View>: UIViewRepresentable  {
    public typealias Offset = ScrollView<Content>.ContentOffset
    public typealias UIViewType = UIHostingScrollView<Content>
    
    private let content: Content
    
    private var configuration = CocoaScrollViewConfiguration<Content>()
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        
        configuration.axes = axes
        configuration.showsIndicators = showsIndicators
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        UIHostingScrollView(rootView: content)
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        var configuration = self.configuration
        
        configuration.initialContentAlignment = context.environment.initialContentAlignment
        configuration.isScrollEnabled = context.environment.isScrollEnabled
        
        uiView.configuration = configuration
        uiView.rootView = content
    }
}

// MARK: - API -

extension CocoaScrollView {
    public func isPagingEnabled(_ enabled: Bool) -> Self {
        then({ $0.configuration.isPagingEnabled = enabled })
    }
    
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

struct _CocoaScrollViewPage: Equatable {
    let index: Int
    let rect: CGRect
}

extension View {
    public func scrollPage(index: Int) -> some View {
        background(GeometryReader { geometry in
            Color.clear.preference(
                key: ArrayReducePreferenceKey<_CocoaScrollViewPage>.self,
                value: [_CocoaScrollViewPage(index: index, rect: geometry.frame(in: .global))]
            )
        })
    }
}
