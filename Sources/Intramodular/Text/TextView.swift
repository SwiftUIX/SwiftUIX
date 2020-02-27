//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    private let label: Label
    
    @Binding private var text: String
    
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            label.hidden(!text.isEmpty)
            
            _TextView(
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
}

fileprivate struct _TextView {
    @Binding private var text: String
    
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    @Environment(\.isScrollEnabled) private var isScrollEnabled
    
    init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
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
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

#if os(iOS) || os(tvOS)

import UIKit

// MARK: - Protocol Implementations -

extension _TextView: UIViewRepresentable {
    typealias UIViewType = _UITextView
    
    class Coordinator: NSObject, UITextViewDelegate {
        var view: _TextView
        
        init(_ view: _TextView) {
            self.view = view
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            view.onEditingChanged(true)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            view.text = textView.text
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
        _UITextView().then {
            $0.delegate = context.coordinator
        }
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        var cursorOffset: Int?
        
        // Record the current cursor offset.
        if let selectedRange = uiView.selectedTextRange {
            cursorOffset = uiView.offset(from: uiView.beginningOfDocument, to: selectedRange.start)
        }
        
        if let font = context.environment.font {
            uiView.font = font.toUIFont()
        } else {
            uiView.font = .preferredFont(forTextStyle: .body)
        }
        
        uiView.backgroundColor = nil
        uiView.isScrollEnabled = isScrollEnabled
        uiView.isSelectable = true
        uiView.text = text
        uiView.textContainerInset = .zero
        
        // Reset the cursor offset if possible.
        if let cursorOffset = cursorOffset, let position = uiView.position(from: uiView.beginningOfDocument, offset: cursorOffset), let textRange = uiView.textRange(from: position, to: position) {
            uiView.selectedTextRange = textRange
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

#elseif canImport(AppKit)

import AppKit

extension _TextView: NSViewRepresentable {
    typealias NSViewType = _NSTextView
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var view: _TextView
        
        init(_ view: _TextView) {
            self.view = view
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            view.text = textView.string
            
            view.onEditingChanged(true)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            view.text = textView.string
        }
        
        func textDidEndEditing(_ notification: Notification) {
            view.onEditingChanged(false)
            view.onCommit()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let nsView = _NSTextView()
        
        nsView.delegate = context.coordinator
        
        nsView.backgroundColor = .clear
        nsView.textContainerInset = .zero
        
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.string = text
    }
}

class _NSTextView: NSTextView {
    
}

#endif

#endif
