//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_ActionButton: opaque_ActionTriggerView {
    
}

/// A button whose primary action can be modified even after construction.
public struct ActionButton<Label: View>: opaque_ActionButton, ActionTriggerView {
    private let label: Label
    private var actions: Actions
    
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.actions = .init()
        
        self.actions.insert(action)
    }
    
    public var body: some View {
        Button(action: { self.actions.perform() }, label: { label })
    }
    
    public func onPrimaryTrigger(perform action: @escaping () -> ()) -> ActionButton {
        then({ $0.actions.insert(action) })
    }
}
