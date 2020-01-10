//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct VibrancyEffectView<Content: View>: View {
    private let content: Content
    private let blurStyle: UIBlurEffect.Style
    private let vibrancyStyle: UIVibrancyEffectStyle
    
    public init(
        blurStyle: UIBlurEffect.Style,
        vibrancyStyle: UIVibrancyEffectStyle,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
    }
    
    public var body: some View {
        VisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: blurStyle), style: vibrancyStyle)) {
            content
        }
    }
}

#endif
