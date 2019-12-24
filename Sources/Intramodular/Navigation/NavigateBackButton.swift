//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct NavigateBackButton<Label: View>: View {
    private let onDismiss: () -> ()
    private let label: Label
    
    public init(
        onDismiss: @escaping () -> (),
        @ViewBuilder label: () -> Label
    ) {
        self.onDismiss = onDismiss
        self.label = label()
    }
    
    public var body: some View {
        DismissPresentationButton(action: onDismiss, label: { label })
    }
}

extension NavigateBackButton: ActionTriggerView {
    public func onPrimaryTrigger(perform action: @escaping () -> ()) -> Self {
        .init(onDismiss: { action(); return self.onDismiss() }, label: { label })
    }
}
