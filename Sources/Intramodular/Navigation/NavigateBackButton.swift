//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct NavigateBackButton<Label: View>: View {
    @Environment(\.presentationMode) private var presentationMode
    
    private let label: Label
    
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }
    
    public var body: some View {
        Button(action: trigger) {
            label
        }
    }
    
    private func trigger() {
        presentationMode.dismiss()
    }
}
