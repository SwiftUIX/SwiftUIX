//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ListRowManager {
    /// Whether the row is highlighted or not.
    var isHighlighted: Bool { get }
    
    /// Animate and invoke `action`.
    func _animate(_ action: () -> ())
    
    /// Trigger a reload.
    func _reload()
}

// MARK: - Auxiliary Implementation -

struct ListRowManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: ListRowManager? = nil
}

extension EnvironmentValues {
    public var listRowManager: ListRowManager? {
        get {
            self[ListRowManagerEnvironmentKey]
        } set {
            self[ListRowManagerEnvironmentKey] = newValue
        }
    }
}
