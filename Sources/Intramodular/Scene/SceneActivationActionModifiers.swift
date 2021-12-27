//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

struct SceneActivationActionModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
                self.action()
            }
    }
}

struct SceneDeactivationActionModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)) { _ in
                self.action()
            }
    }
}

// MARK: - API -

extension View {
    public func onSceneActivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneActivationActionModifier(action: action))
    }

    public func onSceneDeactivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneDeactivationActionModifier(action: action))
    }
}

#endif
