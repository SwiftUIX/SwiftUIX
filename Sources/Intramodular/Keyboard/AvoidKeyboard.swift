//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUI

private struct AvoidKeyboard: ViewModifier {
    let animation: Animation?
    
    @State var padding: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.padding)
                .onReceive(self.keyboardHeightPublisher, perform: { keyboardHeight in
                    self.padding = max(0, min((UIResponder.firstResponder?.globalFrame?.maxY ?? 0) - (geometry.frame(in: .global).height - keyboardHeight), keyboardHeight) - geometry.safeAreaInsets.bottom)
                })
                .animation(self.animation)
        }
    }
    
    private var keyboardHeightPublisher: Publishers.Merge<Publishers.CompactMap<NotificationCenter.Publisher, CGFloat>, Publishers.Map<NotificationCenter.Publisher, CGFloat>> {
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
}

#endif

// MARK: - API -

extension View {
    public func keyboardAvoiding(animation: Animation = .spring()) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return modifier(AvoidKeyboard(animation: animation))
        #else
        return self
        #endif
    }
}
