//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public enum ViewIdentityDestroyTrigger {
    case appear
    case disappear
}

private struct _ViewIdentityDestroyer<Content: View>: View {
    let content: Content
    let destroyEvents: Set<ViewIdentityDestroyTrigger>
    
    @State private var id = UUID()
    
    var body: some View {
        content
            .id(id)
            .onAppKitOrUIKitViewControllerResolution(
                perform: { _ in },
                onAppear: { _ in destroyIfNecessary(for: .appear) },
                onDisappear: { _ in destroyIfNecessary(for: .disappear) },
                onRemoval: { _ in }
            )
            .onAppear {
                destroyIfNecessary(for: .appear)
            }
            .onDisappear {
                destroyIfNecessary(for: .disappear)
            }
    }
    
    private func destroyIfNecessary(for event: ViewIdentityDestroyTrigger) {
        if destroyEvents.contains(event) {
            id = UUID()
        }
    }
}

// MARK: - API -

extension View {
    public func resetIdentity(on events: Set<ViewIdentityDestroyTrigger>) -> some View {
        _ViewIdentityDestroyer(content: self, destroyEvents: events)
    }
}

#endif
