//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _opaque_PerformActionView: _opaque_View {
    func transformAction(_: (Action) -> Action) -> Self
}

/// A view with the primary goal of triggering an action.
public protocol PerformActionView: _opaque_PerformActionView, View {
    func transformAction(_: (Action) -> Action) -> Self
    func addAction(_: Action) -> Self
}

// MARK: - Implementation -

extension PerformActionView {
    public func addAction(_ action: Action) -> Self {
        transformAction({ $0.append(action) })
    }
    
    public func addAction(_ action: @escaping () -> Void) -> Self {
        addAction(.init(action))
    }
}

// MARK: - Extensions -

extension PerformActionView {
    public func insertAction(_ action: Action) -> Self {
        transformAction({ $0.append(action) })
    }
    
    public func insertAction(_ action: @escaping () -> Void) -> Self {
        transformAction({ $0.append(action) })
    }
    
    public func appendAction(_ action: Action) -> Self {
        transformAction({ $0.append(action) })
    }
}

// MARK: - Auxiliary Implementation -

extension ModifiedContent: _opaque_PerformActionView, PerformActionView where Content: PerformActionView, Modifier: ViewModifier {
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        Self.init(content: content.transformAction(transform), modifier: modifier)
    }
}
