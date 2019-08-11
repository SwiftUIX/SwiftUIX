//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct NavigationPresentationLink<Label: View, Destination: View>: View {
    @State private var isActive: Bool = false

    private let destination: Destination
    private let label: Label

    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    public var body: some View {
        NavigationLink(
            destination: destination
                .environment(\.isNavigationButtonActive, $isActive),
            isActive: $isActive,
            label: { label }
        )
    }
}

// MARK: - Helpers -

public struct IsNavigationButtonActiveEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Binding<Bool>? {
        return nil
    }
}

extension EnvironmentValues {
    public var isNavigationButtonActive: Binding<Bool>? {
        get {
            self[IsNavigationButtonActiveEnvironmentKey.self]
        } set {
            self[IsNavigationButtonActiveEnvironmentKey.self] = newValue
        }
    }
}
