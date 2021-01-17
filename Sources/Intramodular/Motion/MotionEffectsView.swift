#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit
import SwiftUI

/// Adapts `UIKit`'s motion effects to `SwiftUI`.
public struct MotionEffectsView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = UIHostingMotionEffectsView<Content>
    
    private let content: Content
    private let magnitude: CGFloat
    
    /// Creates a view that applies a `UIMotionEffectGroup` that will
    /// animate the supplied `content` based on accelerometer data with
    /// a maximum offset defined by `magnitude`.
    /// 
    /// - Parameters:
    ///   - magnitude: the maximum offset by which to limit the translation.
    ///   - content: a `SwiftUI.View` to apply the effect to.
    public init(
        magnitude: CGFloat = 30,
        @ViewBuilder content: () -> Content
    ) {
        self.magnitude = magnitude
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        .init(magnitude: self.magnitude, rootView: content)
    }
    
    public func updateUIView(_ view: UIViewType, context: Context) {
        view.rootView = content
    }
}

extension MotionEffectsView where Content == EmptyView {
    public init() {
        self.init() {
            EmptyView()
        }
    }
}

#endif
