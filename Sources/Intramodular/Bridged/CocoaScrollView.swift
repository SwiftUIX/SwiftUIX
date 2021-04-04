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
        uiView.isUserInteractionEnabled = context.environment.isEnabled
        
        uiView.configuration = configuration.updating(from: context.environment)
        uiView.rootView = content
    }
}

// MARK: - API -

extension CocoaScrollView {
    public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        then({ $0.configuration.alwaysBounceVertical = alwaysBounceVertical })
    }
    
    public func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        then({ $0.configuration.alwaysBounceHorizontal = alwaysBounceHorizontal })
    }
    
    public func isPagingEnabled(_ enabled: Bool) -> Self {
        then({ $0.configuration.isPagingEnabled = enabled })
    }
    
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.configuration.onOffsetChange = body })
    }
    
    public func contentOffset(_ contentOffset: Binding<CGPoint>) -> Self {
        then({ $0.configuration.contentOffset = contentOffset })
    }
    
    public func contentInsets(_ contentInset: EdgeInsets) -> Self {
        then({ $0.configuration.contentInset = contentInset })
    }
    
    @_disfavoredOverload
    public func contentInsets(_ insets: UIEdgeInsets) -> Self {
        contentInsets(EdgeInsets(insets))
    }
    
    public func contentInsets(
        _ edges: Edge.Set = .all,
        _ length: CGFloat = 0
    ) -> Self {
        contentInsets(EdgeInsets(edges, length))
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
    
    public func refreshControlTintColor(_ color: UIColor?) -> Self {
        then({ $0.configuration.refreshControlTintColor = color })
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
