//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A button that triggers a progression.
public struct NextButton<Label: View> {
    @Environment(\.progressionController) var progressionController
    
    private let label: Label
    
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }
    
    public var body: some View {
        Button(action: moveToPrevious) {
            label
        }
    }
    
    private func moveToPrevious() {
        progressionController?.moveToNext()
    }
}
