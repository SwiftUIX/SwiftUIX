//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A button that creates and stores an `AnyCancellable`.
public struct AnyCancellableButton<Label: View>: View {
    private let makeCancellable: () -> AnyCancellable
    private var action: Action = .empty
    private let label: Label
    
    @State private var cancellable: AnyCancellable?
    
    public init(
        action: @escaping () -> AnyCancellable,
        @ViewBuilder label: () -> Label
    ) {
        self.makeCancellable = action
        self.label = label()
    }
    
    public init<C: Cancellable>(
        action: @escaping () -> C,
        @ViewBuilder label: () -> Label
    ) {
        self.makeCancellable = { AnyCancellable(action()) }
        self.label = label()
    }
    
    public var body: some View {
        Button(action: trigger) {
            label
        }
    }
    
    private func trigger() {
        cancellable = makeCancellable()
    }
}

// MARK: - Conformances -

extension AnyCancellableButton: PerformActionView {
    public func transformAction(_ transform: (Action) -> Action) -> Self {
        then {
            $0.action = transform($0.action)
        }
    }
}
