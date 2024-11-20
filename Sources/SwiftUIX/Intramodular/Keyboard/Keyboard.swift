//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI
import UIKit

/// An object representing the keyboard.
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@_documentation(visibility: internal)
public final class Keyboard: ObservableObject {
    public static let main = Keyboard()
    
    @Published public private(set) var state: State = .default
    @Published public private(set) var isShown: Bool = false
    
    /// A Boolean value that determines whether the keyboard is showing on-screen.
    public var isShowing: Bool {
        state.height.map({ $0 != 0 }) ?? false
    }
    
    public var isActive: Bool {
        isShowing || isShown
    }
    
    private var keyboardWillChangeFrameSubscription: AnyCancellable?
    private var keyboardDidChangeFrameSubscription: AnyCancellable?
    private var keyboardWillShowSubscription: AnyCancellable?
    private var keyboardDidShowSubscription: AnyCancellable?
    private var keyboardWillHideSubscription: AnyCancellable?
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
        
        self.keyboardWillShowSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in self._objectWillChange_send() })
        
        self.keyboardDidShowSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardDidShowNotification)
            .compactMap({ Keyboard.State(notification: $0, screen: .main) })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in self.isShown = true })
            .assign(to: \.state, on: self)
        
        self.keyboardWillHideSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in self._objectWillChange_send() })
        
        self.keyboardDidHideSubscription = notificationCenter
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in self.isShown = false })
            .map({ _ in .init() })
            .assign(to: \.state, on: self)
        #endif
    }
    
    /// Dismiss the software keyboard presented on-screen.
    public func dismiss() {
        if isShowing {
            UIApplication.shared.firstKeyWindow?.endEditing(true)
        }
    }
    
    /// Dismiss the software keyboard presented on-screen.
    public class func dismiss() {
        if Keyboard.main.isShowing {
            UIApplication.shared.firstKeyWindow?.endEditing(true)
        }
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
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

#endif
