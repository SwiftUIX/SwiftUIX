//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A checkbox control.
public struct Checkbox: View {
    @State public var isOn: Bool = false

    public var body: some View {
        Button(action: {
            self.isOn.toggle()
        }) { isOn
            ? Image(systemName: "checkmark.square.fill")
            : Image(systemName: "checkmark.square")
            }
            .frame(width: 25, height: 25)
    }
}
