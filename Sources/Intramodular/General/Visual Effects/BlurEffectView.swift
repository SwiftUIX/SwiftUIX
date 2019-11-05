//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

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
    }
}

public struct Label: AppKitOrUIKitViewRepresentable {
    @Environment(\.font) private var font
    
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitLabel
    
    private var text: String
    
    public init(_ text: String) {
        self.text = text
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType().then {
            $0.font = font?.toUIFont()
            $0.text = text
        }
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.font = font?.toUIFont()
        view.text = text
    }
}

#endif
