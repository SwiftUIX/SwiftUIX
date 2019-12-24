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
    private var actionList: [() -> ()] = []
    
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.actionList.append(action)
    }
    
    public var body: some View {
        Button(action: performActionList) {
            label
        }
    }
    
    private func performActionList() {
        actionList.forEach({ $0() })
    }
    
    public func onPrimaryTrigger(perform action: @escaping () -> ()) -> ActionButton {
        then {
            $0.actionList.append(action)
        }
    }
}
