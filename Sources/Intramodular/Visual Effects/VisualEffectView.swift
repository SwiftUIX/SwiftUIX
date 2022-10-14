//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct VisualEffectView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = UIVisualEffectView
    
    private let rootView: Content
    private let effect: UIVisualEffect
    
    public init(effect: UIVisualEffect, @ViewBuilder content: () -> Content) {
        self.rootView = content()
        self.effect = effect
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        UIVisualEffectView(effect: effect).then {
            $0.contentView.constrainSubview(UIHostingView(rootView: rootView))
        }
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView.contentView.subviews.first as! UIHostingView<Content>).rootView = rootView
        uiView.effect = effect
    }
}

#endif
