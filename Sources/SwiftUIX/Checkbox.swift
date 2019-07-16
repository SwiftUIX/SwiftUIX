//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A checkbox control.
public struct Checkbox<Label: View>: View {
    /// A view that describes the effect of toggling `isOn`.
    public let label: Label

    /// Whether or not `self` is currently "on" or "off".
    @Binding public var isOn: Bool

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.$isOn = isOn
        self.label = label()
    }

    public var body: some View {
        HStack {
            label
            Button(action: toggle) {
                isOn
                    ? Image(systemName: "checkmark.square.fill")
                    : Image(systemName: "checkmark.square")
            }
        }
    }

    func toggle() {
        isOn.toggle()
    }
}
