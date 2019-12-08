//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ActionLabelView: View {
    associatedtype Label: View
    
    init(action: @escaping () -> (), @ViewBuilder label: () -> Label)
}

// MARK: - Extensions -

extension ActionLabelView {
    public init(toggle boolean: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.init(action: { boolean.wrappedValue.toggle() }, label: label)
    }
}

// MARK: - Concrete Implementaitons -

extension Button: ActionLabelView {
    
}
