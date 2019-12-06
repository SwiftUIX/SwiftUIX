//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI
import UIKit

/// An object representing the keyboard.
public final class Keyboard: ObservableObject {
    public static let main = Keyboard()
    
    @Published public var state: State = .default
    
    public var isShowing: Bool {
        return state.height != 0
    }
    
    private var subscription: AnyCancellable?
    
    public init(notificationCenter: NotificationCenter = .default) {
        self.subscription = notificationCenter
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap({ Keyboard.State(notification: $0, screen: .main) })
            .assign(to: \.state, on: self)
    }
    
    public class func dismiss() {
        UIApplication.shared.firstKeyWindow?.endEditing(true)
    }
}

extension Keyboard {
    public struct State {
        public static let `default` = State()
        
        public let animationDuration: TimeInterval
        public let animationCurve: UInt?
        public let keyboardFrame: CGRect?
        public let height: CGFloat?
        
        private init() {
            self.animationDuration = 0.25
            self.animationCurve = 0
            self.keyboardFrame = nil
            self.height = nil
        }
        
        init?(notification: Notification, screen: Screen) {
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
        }
    }
}

#endif
