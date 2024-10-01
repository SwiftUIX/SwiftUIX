//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A control which dismisses an active presentation when triggered.
@_documentation(visibility: internal)
@MainActor
public struct DismissPresentationButton<Label: View>: ActionLabelView {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.presentationManager) private var presentationManager
    @Environment(\.presenter) private var presenter
    
    private let action: Action
    private let label: Label
    
    public init(action: Action, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public init(@ViewBuilder label: () -> Label) {
        self.init(action: .empty, label: label)
    }
    
    public var body: some View {
        Button(action: dismiss, label: { label })
            .modify { content in
                if #available(iOS 14.0, macOS 11.0, tvOS 17.0, watchOS 9.0, *) {
                    #if !os(tvOS) && !os(watchOS)
                    content
                        .keyboardShortcut("w")
                    #else
                    content
                    #endif
                } else {
                    content
                }
            }
    }
    
    public func dismiss() {
        defer {
            action.perform()
        }
        
        if presentationManager.isPresented {
            if let presenter = presenter, presentationManager is Binding<PresentationMode> {
                presenter.dismissTopmost()
            } else {
                presentationManager.dismiss()
                
                if presentationMode.isPresented {
                    presentationMode.dismiss()
                }
            }
        } else {
            presentationMode.dismiss()
        }
    }
}

extension DismissPresentationButton where Label == Image {
    @available(OSX 11.0, *)
    public init(action: @MainActor @escaping () -> Void = { }) {
        self.init(action: action) {
            Image(systemName: .xmarkCircleFill)
        }
    }
}

extension DismissPresentationButton where Label == Text {
    public init<S: StringProtocol>(_ title: S) {
        self.init {
            Text(title)
        }
    }
}
