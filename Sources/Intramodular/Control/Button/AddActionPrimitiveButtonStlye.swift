//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct AddActionPrimitiveButtonStlye: PrimitiveButtonStyle {
    var action: () -> ()
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.trigger(); self.action() }) {
            configuration.label
        }
    }
}

extension View {
    @ViewBuilder
    public func onButtonAction(_ action: @escaping () -> ()) -> some View {
        if self is opaque_ActionButton {
            (self as! opaque_ActionButton)
                .onPrimaryTrigger(perform: action)
                .eraseToAnyView()
        } else {
            buttonStyle(AddActionPrimitiveButtonStlye(action: action))
        }
    }
}
