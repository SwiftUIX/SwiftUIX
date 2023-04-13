//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
public struct TextView<Label: View>: View {
    struct _Configuration {
        var isConstant: Bool
        var onEditingChanged: (Bool) -> Void
        var onCommit: () -> Void
        var onDeleteBackward: () -> Void = { }
        
        var isInitialFirstResponder: Bool?
        var isFirstResponder: Bool?
        var isFocused: Binding<Bool>? = nil
        
        var isEditable: Bool = true
        var isSelectable: Bool = true
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        var autocapitalization: UITextAutocapitalizationType?
        #endif
        var font: AppKitOrUIKitFont?
        var textColor: AppKitOrUIKitColor?
		var tintColor: AppKitOrUIKitColor?
        var kerning: CGFloat?
        var linkForegroundColor: AppKitOrUIKitColor?
        var textContainerInset: AppKitOrUIKitInsets = .init(EdgeInsets.zero)
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        var textContentType: UITextContentType?
        #endif
        var dismissKeyboardOnReturn: Bool = false
        var enablesReturnKeyAutomatically: Bool?
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        var keyboardType: UIKeyboardType = .default
        var returnKeyType: UIReturnKeyType?
        #endif
        
        var requiresAttributedText: Bool {
            kerning != nil
        }
    }
    
    @Environment(\.preferredMaximumLayoutWidth) private var preferredMaximumLayoutWidth
    
    private var label: Label
    private var text: Binding<String>?
    private var attributedText: Binding<NSAttributedString>?
    private var configuration: _Configuration
    
    private var customAppKitOrUIKitClass: AppKitOrUIKitTextView.Type = _CocoaTextView<Label>.self
    
    private var isEmpty: Bool {
        text?.wrappedValue.isEmpty ?? attributedText!.wrappedValue.string.isEmpty
    }
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            label
                .font(configuration.font.map(Font.init))
                .visible(isEmpty)
                .animation(.none)
                .padding(configuration.textContainerInset.edgeInsets)
            
            _TextView<Label>(
                text: text,
                attributedText: attributedText,
                configuration: configuration,
                customAppKitOrUIKitClass: customAppKitOrUIKitClass
            )
        }
    }
}

// MARK: - Implementation

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
fileprivate struct _TextView<Label: View> {
    typealias Configuration = TextView<Label>._Configuration
    
    let text: Binding<String>?
    let attributedText: Binding<NSAttributedString>?
    let configuration: Configuration
    let customAppKitOrUIKitClass: AppKitOrUIKitTextView.Type
}

#if os(iOS) || os(tvOS)

import UIKit

extension _TextView: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView: UIViewType
        
        if let customAppKitOrUIKitClass = customAppKitOrUIKitClass as? _CocoaTextView<Label>.Type {
            uiView = customAppKitOrUIKitClass.init(configuration: configuration)
        } else {
            uiView = customAppKitOrUIKitClass.init()
        }
        
        uiView.delegate = context.coordinator
        uiView.backgroundColor = nil
        
        if context.environment.isEnabled {
            DispatchQueue.main.async {
                if (configuration.isInitialFirstResponder ?? configuration.isFocused?.wrappedValue) ?? false {
                    uiView.becomeFirstResponder()
                }
            }
        }
        
        return uiView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        _withoutAppKitOrUIKitAnimation(context.transaction.animation == nil) {
            if let uiView = uiView as? _CocoaTextView<Label> {
                uiView._isSwiftUIRuntimeUpdateActive = true
                
                defer {
                    uiView._isSwiftUIRuntimeUpdateActive = false
                }
                
                uiView.configuration = configuration
            }
            
            _updateUIView(uiView, context: context)
        }
    }
    
    private func _updateUIView(_ uiView: UIViewType, context: Context) {
        var cursorOffset: Int?
        
        // Record the current cursor offset.
        if let selectedRange = uiView.selectedTextRange {
            cursorOffset = uiView.offset(from: uiView.beginningOfDocument, to: selectedRange.start)
        }
        
        updateUserInteractability: do {
            #if !os(tvOS)
            if !configuration.isEditable {
                uiView.isEditable = false
            } else {
                uiView.isEditable = configuration.isConstant
                    ? false
                    : context.environment.isEnabled && configuration.isEditable
            }
            #endif
            uiView.isScrollEnabled = context.environment._isScrollEnabled
            uiView.isSelectable = configuration.isSelectable
        }
        
        updateLayoutConfiguration: do {
            (uiView as? _CocoaTextView<Label>)?.preferredMaximumDimensions = context.environment.preferredMaximumLayoutDimensions
        }
        
        updateTextAndGeneralConfiguration: do {
            if #available(iOS 14.0, tvOS 14.0, *) {
                uiView.overrideUserInterfaceStyle = .init(context.environment.colorScheme)
            }
            
            uiView.autocapitalizationType = configuration.autocapitalization ?? .sentences
            
            let font = configuration.font
                ?? (try? context.environment.font?.toAppKitOrUIKitFont())
                ?? AppKitOrUIKitFont.preferredFont(forTextStyle: .body)
            
            if let textColor = configuration.textColor {
                assignIfNotEqual(textColor, to: &uiView.textColor)
            }
			
			if let tintColor = configuration.tintColor {
                assignIfNotEqual(tintColor, to: &uiView.tintColor)
			}
            
            if let linkForegroundColor = configuration.linkForegroundColor {
                assignIfNotEqual(linkForegroundColor, to: &uiView.linkTextAttributes[.foregroundColor])
            } else {
                if uiView.linkTextAttributes[.foregroundColor] != nil {
                    uiView.linkTextAttributes[.foregroundColor] = nil
                }
            }
            
            uiView.textContentType = configuration.textContentType
            
            uiView.textContainer.lineFragmentPadding = .zero
            uiView.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
            uiView.textContainerInset = configuration.textContainerInset
            
            let requiresAttributedText = false
                || context.environment.requiresAttributedText
                || configuration.requiresAttributedText
                || attributedText != nil
            
            if requiresAttributedText {
                let paragraphStyle = NSMutableParagraphStyle()

                assignIfNotEqual(context.environment.lineBreakMode, to: &paragraphStyle.lineBreakMode)
                assignIfNotEqual(context.environment.lineSpacing, to: &paragraphStyle.lineSpacing)

                context.environment._paragraphSpacing.map {
                    paragraphStyle.paragraphSpacing = $0
                }
                
                if let text = text {
                    var attributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                        NSAttributedString.Key.font: font
                    ]
                    
                    if let kerning = configuration.kerning {
                        assignIfNotEqual(kerning, to: &attributes[.kern])
                    }
                    
                    if let textColor = configuration.textColor {
                        assignIfNotEqual(textColor, to: &attributes[.foregroundColor])
                    }
                    
                    uiView.attributedText = NSAttributedString(
                        string: text.wrappedValue,
                        attributes: attributes
                        
                    )
                } else if let attributedText = attributedText {
                    if uiView.attributedText != attributedText.wrappedValue {
                        uiView.attributedText = attributedText.wrappedValue
                    }
                }
            } else {
                uiView.text = text!.wrappedValue
                uiView.font = font
            }
        }
        
        correctCursorOffset: do {
            #if os(tvOS)
            if let cursorOffset = cursorOffset, let position = uiView.position(from: uiView.beginningOfDocument, offset: cursorOffset), let textRange = uiView.textRange(from: position, to: position) {
                uiView.selectedTextRange = textRange
            }
            #else
            // Reset the cursor offset if possible.
            if uiView.isEditable, let cursorOffset = cursorOffset, let position = uiView.position(from: uiView.beginningOfDocument, offset: cursorOffset), let textRange = uiView.textRange(from: position, to: position) {
                uiView.selectedTextRange = textRange
            }
            #endif
        }
        
        updateKeyboardConfiguration: do {
            uiView.enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically ?? false
            uiView.keyboardType = configuration.keyboardType
            uiView.returnKeyType = configuration.returnKeyType ?? .default
        }
        
        updateResponderChain: do {
            DispatchQueue.main.async {
                if let isFocused = configuration.isFocused, uiView.window != nil {
                    if isFocused.wrappedValue && !uiView.isFirstResponder {
                        uiView.becomeFirstResponder()
                    } else if !isFocused.wrappedValue && uiView.isFirstResponder {
                        uiView.resignFirstResponder()
                    }
                } else if let isFirstResponder = configuration.isFirstResponder, uiView.window != nil {
                    if isFirstResponder && !uiView.isFirstResponder, context.environment.isEnabled {
                        uiView.becomeFirstResponder()
                    } else if !isFirstResponder && uiView.isFirstResponder {
                        uiView.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
        if let uiView = uiView as? _CocoaTextView<Label> {
            uiView._isSwiftUIRuntimeDismantled = true
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>?
        var attributedText: Binding<NSAttributedString>?
        var configuration: Configuration
        
        init(
            text: Binding<String>?,
            attributedText: Binding<NSAttributedString>?,
            configuration: Configuration
        ) {
            self.text = text
            self.attributedText = attributedText
            self.configuration = configuration
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            configuration.onEditingChanged(true)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let textView = textView as? _CocoaTextView<Label>, textView._isSwiftUIRuntimeDismantled {
                return
            }
            
            guard textView.markedTextRange == nil, text?.wrappedValue != textView.text else {
                return
            }
            
            if let text = text {
                text.wrappedValue = textView.text
            } else {
                attributedText?.wrappedValue = textView.attributedText
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if configuration.dismissKeyboardOnReturn {
                if text == "\n" {
                    DispatchQueue.main.async {
                        #if os(iOS)
                        guard textView.isFirstResponder else {
                            return
                        }
                                                
                        self.configuration.onCommit()
                        
                        textView.resignFirstResponder()
                        #endif
                    }
                    
                    return false
                }
            }
            
            return true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.configuration.onEditingChanged(false)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(text: text, attributedText: attributedText, configuration: configuration)
    }
    
    func _overrideSizeThatFits(
        _ size: inout CGSize,
        in proposedSize: _ProposedSize,
        uiView: UIViewType
    ) {
        if let textView = (uiView as? _CocoaTextView<Label>) {
            let proposedSize = _SwiftUIX_ProposedSize(proposedSize)
            
            textView.representableContext.proposedSize = proposedSize
        }
    }
}

#elseif canImport(AppKit)

import AppKit

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension _TextView: NSViewRepresentable {
    typealias NSViewType = _NSTextView<Label>
            
    func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType()
        
        nsView.parent = self
        nsView.delegate = context.coordinator
    
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        if let text = text {
            if nsView.string != text.wrappedValue {
                nsView.string = text.wrappedValue
            }
        } else if let attributedText = attributedText {
            nsView.textStorage?.setAttributedString(attributedText.wrappedValue)
        }
        
        nsView.parent = self
        nsView._update(configuration: configuration, context: context)
        
        nsView.invalidateIntrinsicContentSize()
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: _TextView
        
        init(parent: _TextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            if let text = parent.text {
                text.wrappedValue = textView.string
            } else if let attributedText = parent.attributedText {
                attributedText.wrappedValue = textView.attributedString()
            } else {
                assertionFailure()
            }
            
            parent.configuration.onEditingChanged(true)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            if let text = parent.text {
                text.wrappedValue = textView.string
            } else if let attributedText = parent.attributedText {
                attributedText.wrappedValue = textView.attributedString()
            } else {
                assertionFailure()
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            parent.configuration.onEditingChanged(false)
            
            parent.text?.wrappedValue = textView.string
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
fileprivate class _NSTextView<Label: View>: NSTextView {
    var parent: _TextView<Label>!

    var configuration: _TextView<Label>.Configuration {
        parent.configuration
    }
    
    override var intrinsicContentSize: NSSize {
        guard let manager = textContainer?.layoutManager else {
            return .zero
        }
        
        manager.ensureLayout(for: textContainer!)
        
        return manager.usedRect(for: textContainer!).size
    }
        
    func _update(
        configuration: _TextView<Label>.Configuration,
        context: _TextView<Label>.Context
    ) {
        backgroundColor = .clear
        drawsBackground = false
        isEditable = true
        textContainerInset = configuration.textContainerInset
        usesAdaptiveColorMappingForDarkAppearance = true
        
        font = font ?? (try? configuration.font ?? context.environment.font?.toAppKitOrUIKitFont())
        textColor = configuration.textColor
        
        textStorage?.font = font
        
        isHorizontallyResizable = false
        isVerticallyResizable = true
        autoresizingMask = [.width]

        if let tintColor = configuration.tintColor {
            insertionPointColor = tintColor
        }
    }
    
    override func preferredPasteboardType(
        from availableTypes: [NSPasteboard.PasteboardType],
        restrictedToTypesFrom allowedTypes: [NSPasteboard.PasteboardType]?
    ) -> NSPasteboard.PasteboardType? {
        if availableTypes.contains(.string) {
            return .string
        } else {
            return super.preferredPasteboardType(
                from: availableTypes,
                restrictedToTypesFrom: allowedTypes
            )
        }
    }
            
    override func keyDown(with event: NSEvent) {
        if let shortcut = KeyboardShortcut(from: event) {
            switch shortcut {
                case KeyboardShortcut(.return, modifiers: []):
                    parent.configuration.onCommit()
                default:
                    super.keyDown(with: event)
            }
        } else {
            super.keyDown(with: event)
        }
    }
}

#endif

// MARK: - API

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView where Label == EmptyView {
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self.text = text
        self.configuration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
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
    
    public init(
        _ text: NSAttributedString
    ) {
        self.label = EmptyView()
        self.attributedText = .constant(text)
        self.configuration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public init(
        _ text: AttributedString
    ) {
        self.label = EmptyView()
        self.attributedText = .constant(NSAttributedString(text))
        self.configuration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView: DefaultTextInputType where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.configuration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
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

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
@available(watchOS, unavailable)
extension TextView {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func customAppKitOrUIKitClass(_ type: UITextView.Type) -> Self {
        then({ $0.customAppKitOrUIKitClass = type })
    }
    #endif
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func onDeleteBackward(perform action: @escaping () -> Void) -> Self {
        then({ $0.configuration.onDeleteBackward = action })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.configuration.isInitialFirstResponder = isInitialFirstResponder })
    }
    
    public func isFirstResponder(_ isFirstResponder: Bool) -> Self {
        then({ $0.configuration.isFirstResponder = isFirstResponder })
    }
    
    public func focused(_ isFocused: Binding<Bool>) -> Self {
        then({ $0.configuration.isFocused = isFocused })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.configuration.autocapitalization = autocapitalization })
    }
    #endif
    
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func foregroundColor(_ foregroundColor: Color) -> Self {
        then({ $0.configuration.textColor = foregroundColor.toAppKitOrUIKitColor() })
    }
	
	public func tint(_ tint: Color) -> Self {
		then({ $0.configuration.tintColor = tint.toAppKitOrUIKitColor() })
	}
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func linkForegroundColor(_ linkForegroundColor: Color?) -> Self {
        then({ $0.configuration.linkForegroundColor = linkForegroundColor?.toAppKitOrUIKitColor() })
    }
    #endif
    
    public func font(_ font: AppKitOrUIKitFont?) -> Self {
        then({ $0.configuration.font = font })
    }
    
    @_disfavoredOverload
    public func foregroundColor(_ foregroundColor: AppKitOrUIKitColor) -> Self {
        then({ $0.configuration.textColor = foregroundColor })
    }
    
    @_disfavoredOverload
    public func tint(_ tint: AppKitOrUIKitColor) -> Self {
        then({ $0.configuration.tintColor = tint })
    }
    
    public func kerning(_ kerning: CGFloat) -> Self {
        then({ $0.configuration.kerning = kerning })
    }
    
    @_disfavoredOverload
    public func textContainerInset(_ textContainerInset: AppKitOrUIKitInsets) -> Self {
        then({ $0.configuration.textContainerInset = textContainerInset })
    }
    
    public func textContainerInset(_ textContainerInset: EdgeInsets) -> Self {
        then({ $0.configuration.textContainerInset = AppKitOrUIKitInsets(textContainerInset) })
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.configuration.textContentType = textContentType })
    }
    #endif
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func isEditable(_ isEditable: Bool) -> Self {
        then({ $0.configuration.isEditable = isEditable })
    }
    
    public func isSelectable(_ isSelectable: Bool) -> Self {
        then({ $0.configuration.isSelectable = isSelectable })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func dismissKeyboardOnReturn(_ dismissKeyboardOnReturn: Bool) -> Self {
        then({ $0.configuration.dismissKeyboardOnReturn = dismissKeyboardOnReturn })
    }
    
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        then({ $0.configuration.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.configuration.keyboardType = keyboardType })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.configuration.returnKeyType = returnKeyType })
    }
    #endif
}

#endif

// MARK: - Auxiliary

extension EnvironmentValues {
    struct _ParagraphSpacing: EnvironmentKey {
        static let defaultValue: CGFloat? = nil
    }
    
    var _paragraphSpacing: CGFloat? {
        get {
            self[_ParagraphSpacing.self]
        } set {
            self[_ParagraphSpacing.self] = newValue
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

// MARK: - Helpers

extension EnvironmentValues {
    fileprivate var requiresAttributedText: Bool {
        _paragraphSpacing != nil
    }
}

private extension CGSize {
    var edgeInsets: EdgeInsets {
        .init(
            top: height / 2,
            leading: width / 2,
            bottom: height / 2,
            trailing: width / 2
        )
    }
}
