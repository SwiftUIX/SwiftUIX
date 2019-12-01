//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

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
