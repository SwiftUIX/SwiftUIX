//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view with the primary goal of triggering an action.
public protocol PerformActionView: View {
    func transformAction(_: (Action) -> Action) -> Self
}

// MARK: - Extensions

extension PerformActionView {
    public func insertAction(_ action: Action) -> Self {
        transformAction({ $0.insert(action) })
    }
    
    public func insertAction(_ action: @escaping () -> Void) -> Self {
        transformAction({ $0.insert(action) })
    }
    
    public func appendAction(_ action: Action) -> Self {
        transformAction({ $0.append(action) })
    }
    
    public func appendAction(_ action: @escaping () -> Void) -> Self {
        transformAction({ $0.append(action) })
    }
}

// MARK: - Auxiliary

extension ModifiedContent: PerformActionView where Content: PerformActionView, Modifier: ViewModifier {
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        Self.init(content: content.transformAction(transform), modifier: modifier)
    }
}
