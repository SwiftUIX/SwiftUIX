//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUI

@available(iOSApplicationExtension, unavailable)
private struct KeyboardAvoidance: ViewModifier {
    let isSimple: Bool
    let animation: Animation?
    
    @State var padding: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.padding)
                .onReceive(self.keyboardHeightPublisher, perform: { keyboardHeight in
                    if self.isSimple {
                        self.padding = keyboardHeight > 0 ? keyboardHeight - geometry.safeAreaInsets.bottom : 0
                    } else {
                        self.padding = max(0, min((UIResponder.firstResponder?.globalFrame?.maxY ?? 0) - (geometry.frame(in: .global).height - keyboardHeight), keyboardHeight) - geometry.safeAreaInsets.bottom)
                    }
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

@available(iOSApplicationExtension, unavailable)
extension View {
    public func keyboardAvoiding(animation: Animation = .spring()) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return modifier(KeyboardAvoidance(isSimple: false, animation: animation))
        #else
        return self
        #endif
    }
    
    /// Pads this view with the active system height of the keyboard.
    public func keyboardPadding(animation: Animation = .spring()) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return modifier(KeyboardAvoidance(isSimple: true, animation: animation))
        #else
        return self
        #endif
    }
}
