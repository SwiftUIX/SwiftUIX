//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    @Environment(\.preferredMaximumLayoutWidth) var preferredMaximumLayoutWidth
    
    private let label: Label
    
    @Binding private var text: String
    
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private var customAppKitOrUIKitClass: UITextView.Type = UIHostingTextView<Label>.self
    #endif
    private var appKitOrUIKitFont: AppKitOrUIKitFont?
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            label
                .visible(text.isEmpty)
                .animation(.none)
            
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            _TextView<Label>(
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                customAppKitOrUIKitClass: customAppKitOrUIKitClass,
                appKitOrUIKitFont: appKitOrUIKitFont
            )
            #else
            _TextView<Label>(
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                appKitOrUIKitFont: appKitOrUIKitFont
            )
            #endif
        }
    }
}

// MARK: - Implementation -

fileprivate struct _TextView<Label: View> {
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    var customAppKitOrUIKitClass: UITextView.Type
    #endif
    var appKitOrUIKitFont: AppKitOrUIKitFont?
}

#if os(iOS) || os(tvOS)

import UIKit

extension _TextView: UIViewRepresentable {
    typealias UIViewType = UITextView
    
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
        let result = customAppKitOrUIKitClass.init().then {
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
        
        let font: UIFont = appKitOrUIKitFont ?? context.environment.font?.toUIFont() ?? .preferredFont(forTextStyle: .body)
        
        #if !os(tvOS)
        uiView.isEditable = context.environment.isEnabled
        #endif
        uiView.isScrollEnabled = context.environment.isScrollEnabled
        uiView.isSelectable = true
        
        if context.environment.requiresAttributedText {
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.lineBreakMode = context.environment.lineBreakMode
            paragraphStyle.lineSpacing = context.environment.lineSpacing
            
            context.environment._paragraphSpacing.map {
                paragraphStyle.paragraphSpacing = $0
            }
            
            uiView.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: font
                ]
            )
            
        } else {
            uiView.text = text
            
            // `UITextView`'s default font is smaller than SwiftUI's default font.
            // `.preferredFont(forTextStyle: .body)` is used when `context.environment.font` is nil.
            uiView.font = font
        }
        
        uiView.textContainer.lineFragmentPadding = .zero
        uiView.textContainerInset = .zero
        
        (uiView as? UIHostingTextView<Label>)?.preferredMaximumLayoutWidth = context.environment.preferredMaximumLayoutWidth
        
        // Reset the cursor offset if possible.
        if let cursorOffset = cursorOffset, let position = uiView.position(from: uiView.beginningOfDocument, offset: cursorOffset), let textRange = uiView.textRange(from: position, to: position) {
            uiView.selectedTextRange = textRange
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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

extension TextView: DefaultTextInputType where Label == Text {
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

extension TextView {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func customAppKitOrUIKitClass(_ type: UITextView.Type) -> Self {
        then({ $0.customAppKitOrUIKitClass = type })
    }
    #endif
    
    public func font(_ font: AppKitOrUIKitFont) -> Self {
        then({ $0.appKitOrUIKitFont = font })
    }
}

#endif

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    struct _ParagraphSpacing: EnvironmentKey {
        static let defaultValue: CGFloat? = nil
    }
    
    var _paragraphSpacing: CGFloat? {
        get {
            self[_ParagraphSpacing]
        } set {
            self[_ParagraphSpacing] = newValue
        }
    }
}

extension View {
    /// Sets the amount of space between paragraphs of text in this view.
    ///
    /// Use `paragraphSpacing(_:)` to set the amount of spacing from the bottom of one paragraph to the top of the next for text elements in the view.
    public func paragraphSpacing(_ paragraphSpacing: CGFloat) -> some View {
        environment(\._paragraphSpacing, paragraphSpacing)
    }
}

// MARK: - Helpers -

extension EnvironmentValues {
    fileprivate var requiresAttributedText: Bool {
        _paragraphSpacing != nil
    }
}
