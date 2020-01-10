//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUI

public struct KeyboardAvoiding: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    public var keyBoardHeightPublisher: Publishers.Merge<Publishers.CompactMap<NotificationCenter.Publisher, CGFloat>, Publishers.Map<NotificationCenter.Publisher, CGFloat>> {
        Publishers.Merge(
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap({ $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect })
                .map({ $0.height }),
            
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map({ _ in 0 })
        )
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .animation(Animation.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 1.0))
            .onReceive(keyBoardHeightPublisher, perform: { self.keyboardHeight = $0 })
    }
}

extension View {
    public func keyboardAvoiding() -> some View {
        modifier(KeyboardAvoiding())
    }
}

#endif
