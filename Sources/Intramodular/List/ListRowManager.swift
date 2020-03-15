//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ListRowManager {
    func _animate(_ action: () -> ()) 
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
