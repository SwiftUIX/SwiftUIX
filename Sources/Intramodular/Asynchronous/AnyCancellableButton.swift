//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A button that creates and stores an `AnyCancellable`.
public struct AnyCancellableButton<Label: View>: View {
    private let action: () -> AnyCancellable
    private let label: Label
    
    @State private var cancellable: AnyCancellable?
    
    public init(
        action: @escaping () -> AnyCancellable,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: trigger) {
            label
        }
    }
    
    private func trigger() {
        cancellable = action()
    }
}

// MARK: - Protocol Implementations -

extension AnyCancellableButton: ActionTriggerView {
    public func onPrimaryTrigger(perform action: @escaping () -> ()) -> Self {
        .init(action: { action(); return self.action() }, label: { label })
    }
}
