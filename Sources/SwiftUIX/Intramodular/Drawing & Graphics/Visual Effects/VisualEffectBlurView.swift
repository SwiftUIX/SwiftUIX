//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

@_documentation(visibility: internal)
public struct VisualEffectBlurView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = UIView
    
    private let blurStyle: UIBlurEffect.Style
    private let vibrancyStyle: UIVibrancyEffectStyle?
    private let content: Content
    
    private var intensity: Double = 1.0
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
            rootView: content,
            intensity: intensity
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
        view.intensity = intensity
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
    /// Sets the intensity of the blur effect.
    public func intensity(_ intensity: Double) -> Self {
        then({ $0.intensity = intensity })
    }
    
    /// Sets the transparency of this view.
    public func opacity(_ opacity: Double) -> Self {
        then({ $0.opacity = opacity })
    }
}

#endif
