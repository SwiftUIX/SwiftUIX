//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct VisualEffectBlurView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = UIView
    
    private let blurStyle: UIBlurEffect.Style
    private let vibrancyStyle: UIVibrancyEffectStyle?
    private let content: Content
    
    private var opacity: Double = 1.0
    
    public init(
        blurStyle: UIBlurEffect.Style = .systemMaterial,
        vibrancyStyle: UIVibrancyEffectStyle? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        UIHostingVisualEffectBlurView<Content>(
            blurStyle: blurStyle,
            vibrancyStyle: vibrancyStyle,
            rootView: content
        )
    }
    
    public func updateUIView(_ view: UIViewType, context: Context) {
        guard let view = view as? UIHostingVisualEffectBlurView<Content> else {
            assertionFailure()
            
            return
        }
        
        view.blurStyle = blurStyle
        view.vibrancyStyle = vibrancyStyle
        view.alpha = .init(opacity)
        view.tintColor = context.environment.tintColor?.toUIColor()
        
        view.rootView = content
    }
}

extension VisualEffectBlurView where Content == EmptyView {
    public init(blurStyle: UIBlurEffect.Style = .systemMaterial) {
        self.init(blurStyle: blurStyle, vibrancyStyle: nil) {
            EmptyView()
        }
    }
}

extension VisualEffectBlurView {
    /// Sets the transparency of this view.
    public func opacity(_ opacity: Double) -> Self {
        then({ $0.opacity = opacity })
    }
}

#endif
