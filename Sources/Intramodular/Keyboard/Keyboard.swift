//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI
import UIKit

/// An object representing the keyboard.
@available(iOSApplicationExtension, unavailable)
public final class Keyboard: ObservableObject {
    public static let main = Keyboard()
    
    @Published public var state: State = .default
    
    public var isShowing: Bool {
        state.height.map({ $0 != 0 }) ?? false
    }
    
    private var keyboardWillChangeFrameSubscription: AnyCancellable?
    private var keyboardDidChangeFrameSubscription: AnyCancellable?
    private var keyboardDidHideSubscription: AnyCancellable?
    
    public init(notificationCenter: NotificationCenter = .default) {
        #if os(iOS) || targetEnvironment(macCatalyst)
        
        self.keyboardWillChangeFrameSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap({ Keyboard.State(notification: $0, screen: .main) })
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
        
        self.keyboardDidChangeFrameSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardDidChangeFrameNotification)
            .compactMap({ Keyboard.State(notification: $0, screen: .main) })
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
        
        self.keyboardDidHideSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in self.state = .init() }
        
        #endif
    }
    
    public func dismiss() {
        if isShowing {
            UIApplication.shared.firstKeyWindow?.endEditing(true)
        }
    }
    
    public class func dismiss() {
        if Keyboard.main.isShowing {
            UIApplication.shared.firstKeyWindow?.endEditing(true)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
extension Keyboard {
    public struct State {
        public static let `default` = State()
        
        public let animationDuration: TimeInterval
        public let animationCurve: UInt?
        public let keyboardFrame: CGRect?
        public let height: CGFloat?
        
        init() {
            self.animationDuration = 0.25
            self.animationCurve = 0
            self.keyboardFrame = nil
            self.height = nil
        }
        
        init?(notification: Notification, screen: Screen) {
            #if os(iOS) || targetEnvironment(macCatalyst)
            
            guard
                let userInfo = notification.userInfo,
                let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
                else {
                    return nil
            }
            
            self.animationDuration = animationDuration
            self.animationCurve = animationCurve
            
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardFrame = keyboardFrame
                
                if keyboardFrame.origin.y == screen.bounds.height {
                    self.height = 0
                } else {
                    self.height = keyboardFrame.height
                }
            } else {
                self.keyboardFrame = nil
                self.height = nil
            }
            
            #else
            
            return nil
            
            #endif
        }
    }
}

// MARK: - Helpers -

@available(iOSApplicationExtension, unavailable)
struct HiddenIfKeyboardActive: ViewModifier {
    @ObservedObject var keyboard: Keyboard = .main
    
    func body(content: Content) -> some View {
        content.hidden(keyboard.isShowing)
    }
}

@available(iOSApplicationExtension, unavailable)
struct VisibleIfKeyboardActive: ViewModifier {
    @ObservedObject var keyboard: Keyboard = .main
    
    func body(content: Content) -> some View {
        content.hidden(!keyboard.isShowing)
    }
}

@available(iOSApplicationExtension, unavailable)
struct RemoveIfKeyboardActive: ViewModifier {
    @ObservedObject var keyboard: Keyboard = .main
    
    func body(content: Content) -> some View {
        content.frame(
            width: keyboard.isShowing ? 0 : nil,
            height: keyboard.isShowing ? 0 : nil,
            alignment: .center
        ).clipped()
    }
}

@available(iOSApplicationExtension, unavailable)
struct AddIfKeyboardActive: ViewModifier {
    @ObservedObject var keyboard: Keyboard = .main
    
    func body(content: Content) -> some View {
        content.frame(
            width: keyboard.isShowing ? nil : 0,
            height: keyboard.isShowing ? nil : 0,
            alignment: .center
        ).clipped()
    }
}

@available(iOSApplicationExtension, unavailable)
extension View {
    public func hiddenIfKeyboardActive() -> some View {
        modifier(HiddenIfKeyboardActive())
    }
    
    public func visibleIfKeyboardActive() -> some View {
        modifier(VisibleIfKeyboardActive())
    }
    
    public func removeIfKeyboardActive() -> some View {
        modifier(RemoveIfKeyboardActive())
    }
    
    public func addIfKeyboardActive() -> some View {
        modifier(AddIfKeyboardActive())
    }
}

#endif
