//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import UIKit

/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    private let label: Label

    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void

    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            TextViewCore(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
}

extension TextView where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title)
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

fileprivate struct TextViewCore {
    var text: Binding<String>
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void

    init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

// MARK: - Protocol Implementations -

extension TextViewCore: UIViewRepresentable {
    typealias UIViewType = UITextView

    class Coordinator: NSObject, UITextViewDelegate {
        var view: TextViewCore

        init(_ view: TextViewCore) {
            self.view = view
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            view.onEditingChanged(true)
        }

        func textViewDidChange(_ textView: UITextView) {
            view.text.value = textView.text

            view.onEditingChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            view.onEditingChanged(false)
            view.onCommit()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()

        view.backgroundColor = nil
        view.text = text.value

        if let font = context.environment.font {
            view.font = font.toUIFont()
        } else {
            view.font = .preferredFont(forTextStyle: .body)
        }

        view.textContainerInset = .zero
        view.delegate = context.coordinator

        return view
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if let font = context.environment.font, font.toUIFont() != textView.font {
            textView.font = font.toUIFont()
        }

        textView.text = text.value
    }
}
