//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
public struct CocoaTextField<Label: View>: CocoaView {
    
    typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)
    
    public struct CharactersChange {
        public let range: NSRange
        public let replacement: String
    }
    
    struct _Configuration {
        var onEditingChanged: (Bool) -> Void = { _ in }
        var onCommit: () -> Void
        var onDeleteBackward: () -> Void = { }
        var onCharactersChange: (CharactersChange) -> Bool = { _ in true }
        
        var textRect: Rect?
        var editingRect: Rect?
        var clearButtonRect: Rect?
        
        var isInitialFirstResponder: Bool?
        var isFirstResponder: Bool?
        
        var focusRingType: FocusRingType = .none
        
        var autocapitalization: UITextAutocapitalizationType?
        var borderStyle: UITextField.BorderStyle = .none
        var uiFont: UIFont?
        var inputAccessoryView: AnyView?
        var inputView: AnyView?
        var kerning: CGFloat?
        var keyboardType: UIKeyboardType = .default
        var placeholder: String?
        var returnKeyType: UIReturnKeyType?
        var textColor: UIColor?
        var textContentType: UITextContentType?
        var secureTextEntry: Bool?
        var clearButtonMode: UITextField.ViewMode?
        var enablesReturnKeyAutomatically: Bool?
    }
    
    @Environment(\.font) var font
    @Environment(\.multilineTextAlignment) var multilineTextAlignment: TextAlignment
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @ObservedObject private var keyboard = Keyboard.main
    #endif
    
    private var label: Label
    private var text: Binding<String>
    private var isEditing: Binding<Bool>
    private var configuration: _Configuration
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .init(from: multilineTextAlignment), vertical: .top)) {
            if configuration.placeholder == nil {
                label
                    .font(configuration.uiFont.map(Font.init) ?? font)
                    .opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
                    .animation(nil)
            }
            
            _CocoaTextField<Label>(text: text, isEditing: isEditing, configuration: configuration)
        }
    }
}

fileprivate struct _CocoaTextField<Label: View>: UIViewRepresentable {
    typealias Configuration = CocoaTextField<Label>._Configuration
    typealias UIViewType = _UITextField
    
    let text: Binding<String>
    let isEditing: Binding<Bool>
    let configuration: Configuration
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isEditing: Binding<Bool>
        var configuration: Configuration
        
        init(text: Binding<String>, isEditing: Binding<Bool>, configuration: Configuration) {
            self.text = text
            self.isEditing = isEditing
            self.configuration = configuration
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            isEditing.wrappedValue = true
            configuration.onEditingChanged(true)
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            guard textField.markedTextRange == nil, text.wrappedValue != textField.text else {
                return
            }
            
            text.wrappedValue = textField.text ?? ""
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            isEditing.wrappedValue = false
            configuration.onEditingChanged(false)
        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            configuration.onCharactersChange(.init(range: range, replacement: string))
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            var nextField: UIView?
            
            if textField.tag != 0 {
                let nextTag = textField.tag + 1
                var parentView = textField.superview
                
                while nextField == nil && parentView != nil {
                    nextField = parentView?.viewWithTag(nextTag)
                    parentView = parentView?.superview
                }
            }
            
            if let nextField = nextField {
                nextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            configuration.onCommit()
            return true
        }
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView = _UITextField()
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        uiView.delegate = context.coordinator
        
        if let isFirstResponder = configuration.isInitialFirstResponder, isFirstResponder, context.environment.isEnabled {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
        
        return uiView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.text = text
        context.coordinator.configuration = configuration
        
        #if targetEnvironment(macCatalyst)
        // uiView._focusRingType = configuration.focusRingType
        #endif
        
        uiView.onDeleteBackward = configuration.onDeleteBackward
        
        uiView.textRect = configuration.textRect
        uiView.editingRect = configuration.editingRect
        uiView.clearButtonRect = configuration.clearButtonRect
        
        if let autocapitalization = configuration.autocapitalization {
            uiView.autocapitalizationType = autocapitalization
        } else {
            uiView.autocapitalizationType = .sentences
        }
        
        uiView.borderStyle = configuration.borderStyle
        
        if let disableAutocorrection = context.environment.disableAutocorrection {
            uiView.autocorrectionType = disableAutocorrection ? .no : .yes
        } else {
            uiView.autocorrectionType = .default
        }
        
        uiView.font = configuration.uiFont ?? context.environment.font?.toUIFont()
        
        if let kerning = configuration.kerning {
            uiView.defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        if let inputAccessoryView = configuration.inputAccessoryView {
            if let _inputAccessoryView = uiView.inputAccessoryView as? UIHostingView<AnyView> {
                _inputAccessoryView.rootView = inputAccessoryView
            } else {
                uiView.inputAccessoryView = UIHostingView(rootView: inputAccessoryView)
                uiView.inputAccessoryView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            uiView.inputAccessoryView = nil
        }
        
        if let inputView = configuration.inputView {
            if let _inputView = uiView.inputView as? UIHostingView<AnyView> {
                _inputView.rootView = inputView
            } else {
                uiView.inputView = UIHostingView(rootView: inputView)
                uiView.inputView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            uiView.inputView = nil
        }
        
        uiView.isUserInteractionEnabled = context.environment.isEnabled
        uiView.keyboardType = configuration.keyboardType
        
        if let placeholder = configuration.placeholder {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: configuration.uiFont ?? context.environment.font?.toUIFont() as Any,
                    .paragraphStyle: NSMutableParagraphStyle().then {
                        $0.alignment = .init(context.environment.multilineTextAlignment)
                    }
                ]
            )
        } else {
            uiView.attributedPlaceholder = nil
            uiView.placeholder = nil
        }
        
        if let returnKeyType = configuration.returnKeyType {
            uiView.returnKeyType = returnKeyType
        }
        
        if let textColor = configuration.textColor {
            uiView.textColor = textColor
        }
        
        if let textContentType = configuration.textContentType {
            uiView.textContentType = textContentType
        } else {
            uiView.textContentType = nil
        }
        
        if let secureTextEntry = configuration.secureTextEntry {
            uiView.isSecureTextEntry = secureTextEntry
        } else {
            uiView.isSecureTextEntry = false
        }
        
        if let clearButtonMode = configuration.clearButtonMode {
            uiView.clearButtonMode = clearButtonMode
        } else {
            uiView.clearButtonMode = .never
        }
        
        if let enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically {
            uiView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        } else {
            uiView.enablesReturnKeyAutomatically = false
        }
        
        uiView.text = text.wrappedValue
        uiView.textAlignment = .init(context.environment.multilineTextAlignment)
        
        DispatchQueue.main.async {
            if let isFirstResponder = configuration.isFirstResponder, uiView.window != nil {
                if isFirstResponder && !uiView.isFirstResponder, context.environment.isEnabled {
                    uiView.becomeFirstResponder()
                } else if !isFirstResponder && uiView.isFirstResponder {
                    uiView.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(text: text, isEditing: isEditing, configuration: configuration)
    }
}

// MARK: - Extensions -

extension CocoaTextField where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.isEditing = .constant(false)
        self.configuration = .init(onEditingChanged: onEditingChanged, onCommit: onCommit)
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
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.label = label()
        self.text = text
        self.isEditing = .constant(false)
        self.configuration = .init(onEditingChanged: onEditingChanged, onCommit: onCommit)
    }
}

extension CocoaTextField where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.isEditing = isEditing
        self.configuration = .init(onCommit: onCommit)
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            isEditing: isEditing,
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.label = label()
        self.text = text
        self.isEditing = isEditing
        self.configuration = .init(onCommit: onCommit)
    }
}

extension CocoaTextField {
    public func onDeleteBackward(perform action: @escaping () -> Void) -> Self {
        then({ $0.configuration.onDeleteBackward = action })
    }
    
    /// Adds an action to perform when characters are changed in this text field.
    public func onCharactersChange(perform action: @escaping (CharactersChange) -> Bool) -> Self {
        then({ $0.configuration.onCharactersChange = action })
    }
    
    /// Adds an action to perform when characters are changed in this text field.
    public func onCharactersChange(perform action: @escaping (CharactersChange) -> Void) -> Self {
        then({ $0.configuration.onCharactersChange = { change in action(change); return true } })
    }
}

extension CocoaTextField {
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.configuration.isInitialFirstResponder = isInitialFirstResponder })
    }
    
    public func isFirstResponder(_ isFirstResponder: Bool) -> Self {
        then({ $0.configuration.isFirstResponder = isFirstResponder })
    }
}

extension CocoaTextField {
    public func focusRingType(_ focusRingType: FocusRingType) -> Self {
        then({ $0.configuration.focusRingType = focusRingType })
    }
    
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.configuration.autocapitalization = autocapitalization })
    }
    
    public func borderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        then({ $0.configuration.borderStyle = borderStyle })
    }
    
    public func font(_ uiFont: UIFont) -> Self {
        then({ $0.configuration.uiFont = uiFont })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(_ view: InputAccessoryView) -> Self {
        then({ $0.configuration.inputAccessoryView = .init(view) })
    }
    
    public func inputView<InputView: View>(_ view: InputView) -> Self {
        then({ $0.configuration.inputView = .init(view) })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(@ViewBuilder _ view: () -> InputAccessoryView) -> Self {
        then({ $0.configuration.inputAccessoryView = .init(view()) })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.configuration.keyboardType = keyboardType })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.configuration.placeholder = placeholder })
    }
    
    public func foregroundColor(_ foregroundColor: Color) -> Self {
        then({ $0.configuration.textColor = foregroundColor.toUIColor() })
    }
    
    @_disfavoredOverload
    public func foregroundColor(_ foregroundColor: UIColor) -> Self {
        then({ $0.configuration.textColor = foregroundColor })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.configuration.returnKeyType = returnKeyType })
    }
    
    @available(iOS, deprecated: 13.0, renamed: "foregroundColor(_:)")
    public func textColor(_ foregroundColor: Color) -> Self {
        then({ $0.configuration.textColor = foregroundColor.toUIColor() })
    }
    
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.configuration.textContentType = textContentType })
    }
    
    public func secureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        then({ $0.configuration.secureTextEntry = isSecureTextEntry })
    }
    
    public func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
        then({ $0.configuration.clearButtonMode = clearButtonMode })
    }
    
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        then({ $0.configuration.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
}

extension CocoaTextField where Label == Text {
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.configuration.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then {
            $0.label = Text(placeholder).kerning(configuration.kerning)
            $0.configuration.placeholder = placeholder
        }
    }
}

// MARK: - Auxiliary Implementation -

private final class _UITextField: UITextField {
    var onDeleteBackward: () -> Void = { }
    
    var textRect: CocoaTextField<AnyView>.Rect?
    var editingRect: CocoaTextField<AnyView>.Rect?
    var clearButtonRect: CocoaTextField<AnyView>.Rect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.textRect(forBounds: bounds)
        
        return textRect?(bounds, original) ?? original
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.editingRect(forBounds: bounds)
        
        return editingRect?(bounds, original) ?? original
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.clearButtonRect(forBounds: bounds)
        
        return clearButtonRect?(bounds, original) ?? original
    }
}

#endif
