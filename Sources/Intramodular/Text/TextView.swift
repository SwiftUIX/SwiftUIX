//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import UIKit

#if canImport(UIKit)

/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    private let label: Label

    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void

    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            if text.value.isEmpty {
                label
            }
            
            TextViewCore(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
}

class _UITextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()

        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
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

// MARK: - Extensions -

extension TextView where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

// MARK: - Protocol Implementations -

extension TextViewCore: UIViewRepresentable {
    typealias UIViewType = _UITextView

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

    func makeUIView(context: Context) -> _UITextView {
        let view = _UITextView()

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

    func updateUIView(_ textView: _UITextView, context: Context) {
        if let font = context.environment.font, font.toUIFont() != textView.font {
            textView.font = font.toUIFont()
        }

        textView.text = text.value
    }
}

#endif
