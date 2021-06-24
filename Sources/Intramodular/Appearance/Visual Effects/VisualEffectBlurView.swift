//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct VisualEffectBlurView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = UIHostingVisualEffectBlurView<Content>
    
    private let blurStyle: UIBlurEffect.Style
    private let vibrancyStyle: UIVibrancyEffectStyle?
    private let content: Content
    
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
        .init(blurStyle: blurStyle, vibrancyStyle: vibrancyStyle, rootView: content)
    }
    
    public func updateUIView(_ view: UIViewType, context: Context) {
        view.blurStyle = blurStyle
        view.vibrancyStyle = vibrancyStyle
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

#endif
