//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUI

private struct KeyboardAvoiding: ViewModifier {
    @State var keyboardHeight: CGFloat = 0
    
    var isActive: Bool {
        keyboardHeight != 0
    }
    
    var keyBoardHeightPublisher: Publishers.Merge<Publishers.CompactMap<NotificationCenter.Publisher, CGFloat>, Publishers.Map<NotificationCenter.Publisher, CGFloat>> {
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
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .animation(.spring())
            .onReceive(keyBoardHeightPublisher, perform: { self.keyboardHeight = $0 })
            .edgesIgnoringSafeArea(isActive ? [.bottom] : [])
    }
}

extension View {
    public func keyboardAvoiding() -> some View {
        modifier(KeyboardAvoiding())
    }
}

#endif
