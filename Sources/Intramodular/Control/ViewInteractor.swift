//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// An interface that allows a child view to interact with its parent view..
public protocol ViewInteractor {
    
}

// MARK: - Helpers -

public protocol ViewInteractorEnvironmentKey: EnvironmentKey {
    associatedtype ViewInteractor where Value == ViewInteractor?
}

extension ViewInteractorEnvironmentKey {
    public static var defaultValue: Value {
        return nil
    }
}

// MARK: - Conformances -

extension Binding: ViewInteractor {
    
}
