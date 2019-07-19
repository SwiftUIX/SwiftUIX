//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A checkbox control.
public struct Checkbox<Label: View>: View {
    /// A view that describes the effect of toggling `isOn`.
    public let label: Label

    /// Whether or not `self` is currently "on" or "off".
    public let isOn: Binding<Bool>

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.label = label()
    }

    public var body: some View {
        HStack {
            label
            Button(action: toggle) {
                isOn.value
                    ? Image(systemName: "checkmark.square.fill")
                    : Image(systemName: "checkmark.square")
            }
        }
    }

    private func toggle() {
        isOn.value.toggle()
    }
}
