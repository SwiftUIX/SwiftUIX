//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ProgressionController: ViewInteractor {
    func moveToNext()
    func moveToPrevious()
}

// MARK: - Auxiliary Implementation -

public struct ProgressionControllerEnvironmentKey: ViewInteractorEnvironmentKey {
    public typealias ViewInteractor = ProgressionController
}

extension EnvironmentValues {
    public var progressionController: ProgressionController? {
        get {
            self[ProgressionControllerEnvironmentKey.self]
        } set {
            self[ProgressionControllerEnvironmentKey.self] = newValue
        }
    }
}
