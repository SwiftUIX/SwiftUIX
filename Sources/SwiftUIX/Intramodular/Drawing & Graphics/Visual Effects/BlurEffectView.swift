//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

@_documentation(visibility: internal)
public struct BlurEffectView<Content: View>: View {
    private let content: Content
    private let style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.style = style
    }
    
    public var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: style)) {
            content
        }
        .accessibility(hidden: Content.self == EmptyView.self)
    }
}

extension BlurEffectView where Content == EmptyView {
    public init(style: UIBlurEffect.Style) {
        self.init(style: style) {
            EmptyView()
        }
    }
}

#endif
