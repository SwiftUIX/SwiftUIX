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
