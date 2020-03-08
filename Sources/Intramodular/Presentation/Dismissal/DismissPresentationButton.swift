//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
public struct DismissPresentationButton<Label: View>: View {
    private let label: Label
    private let action: (() -> ())?
    
    @Environment(\.presentationManager) private var presentationManager
    
    public init(action: (() -> ())? = nil, label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: dismiss, label: { label })
    }
    
    public func dismiss() {
        action?()
        presentationManager.dismiss()
    }
}

#if !os(macOS)

extension DismissPresentationButton where Label == Image {
    public init(action: (() -> ())? = nil) {
        self.init(action: action) {
            Image(systemName: .xmarkCircleFill)
        }
    }
}

#endif
