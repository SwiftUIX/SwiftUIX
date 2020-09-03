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
            label
                .visible(text.isEmpty)
                .animation(.none)
            
            _TextView(
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
}

// MARK: - API -

extension TextView where Label == EmptyView {
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public init(
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            text: text.withDefaultValue(String()),
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
}

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
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
}

// MARK: - Implementation -

fileprivate struct _TextView {
    @Binding private var text: String
    
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
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

#if os(iOS) || os(tvOS)

import UIKit

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
    
    func makeUIView(context: Context) -> UIViewType {
        let result = _UITextView().then {
            $0.delegate = context.coordinator
        }
        
        updateUIView(result, context: context)
        
        return result
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        var cursorOffset: Int?
        
        // Record the current cursor offset.
        if let selectedRange = uiView.selectedTextRange {
            cursorOffset = uiView.offset(from: uiView.beginningOfDocument, to: selectedRange.start)
        }
        
        uiView.backgroundColor = nil
        
        // `UITextView`'s default font is smaller than SwiftUI's default font.
        // `.preferredFont(forTextStyle: .body)` is used when `context.environment.font` is nil.
        uiView.font = context.environment.font?.toUIFont() ?? .preferredFont(forTextStyle: .body)
        #if !os(tvOS)
        uiView.isEditable = context.environment.isEnabled
        #endif
        uiView.isScrollEnabled = context.environment.isScrollEnabled
        uiView.isSelectable = true
        uiView.text = text
        uiView.textContainerInset = .zero
        
        // Reset the cursor offset if possible.
        if let cursorOffset = cursorOffset, let position = uiView.position(from: uiView.beginningOfDocument, offset: cursorOffset), let textRange = uiView.textRange(from: position, to: position) {
            uiView.selectedTextRange = textRange
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
