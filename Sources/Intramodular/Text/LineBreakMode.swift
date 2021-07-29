//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct LineBreakMode: EnvironmentKey {
    static let defaultValue: NSLineBreakMode = .byWordWrapping
}

extension EnvironmentValues {
    public var lineBreakMode: NSLineBreakMode {
        get {
            self[LineBreakMode.self]
        } set {
            self[LineBreakMode.self] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> some View {
        environment(\.lineBreakMode, lineBreakMode)
    }
}
