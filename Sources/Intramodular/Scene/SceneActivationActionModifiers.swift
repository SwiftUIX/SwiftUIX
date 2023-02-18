//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

private struct SceneActivationActionModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
                self.action()
            }
    }
}

private struct SceneDeactivationActionModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)) { _ in
                self.action()
            }
    }
}

private struct SceneDisconnectionActionModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didDisconnectNotification)) { _ in
                self.action()
            }
    }
}

// MARK: - API

extension View {
    public func onSceneActivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneActivationActionModifier(action: action))
    }
    
    public func onSceneDeactivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneDeactivationActionModifier(action: action))
    }

    public func onSceneDisconnect(perform action: @escaping () -> Void) -> some View {
        modifier(SceneDisconnectionActionModifier(action: action))
    }
}

#endif
