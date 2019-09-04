//
// Copyright (c) Vatsal Manot
//

#if os(iOS)

import Swift
import SwiftUI
import UIKit

public struct VisualEffectView: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    public typealias UIViewType = UIView

    public let effect: UIVisualEffect

    public init(effect: UIVisualEffect) {
        self.effect = effect
    }

    public func makeUIView(context: Context) -> UIViewType {
        let view = UIView(frame: .zero)
        let effectView = UIVisualEffectView(effect: effect)

        view.backgroundColor = .clear
        effectView.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(effectView, at: 0)

        NSLayoutConstraint.activate([
            effectView.heightAnchor.constraint(equalTo: view.heightAnchor),
            effectView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

#endif
