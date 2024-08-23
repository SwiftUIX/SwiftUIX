//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
@_documentation(visibility: internal)
public struct CocoaTextField<Label: View>: View {
    typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)
    
    public struct CharactersChange: Hashable {
        public let currentText: String
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
        var clearButtonImage: AppKitOrUIKitImage?

        var isInitialFirstResponder: Bool?
        var isFirstResponder: Bool?
        var isFocused: Binding<Bool>? = nil
        
        var focusRingType: FocusRingType = .none
        
        var autocapitalization: UITextAutocapitalizationType?
        var borderStyle: UITextField.BorderStyle = .none
        var clearButtonMode: UITextField.ViewMode?
        var uiFont: UIFont?
        var inputView: AnyView?
        var kerning: CGFloat?
        var placeholder: String?
        var smartDashesType: UITextSmartDashesType?
        var smartQuotesType: UITextSmartQuotesType?
        var spellCheckingType: UITextSpellCheckingType?
        var secureTextEntry: Bool?
        var textColor: UIColor?
        var textContentType: UITextContentType?
        
        // MARK: Input Accessory
        
        var inputAccessoryView: AnyView?
        var inputAssistantDisabled: Bool = false
        
        // MARK: Keyboard
        
        var dismissKeyboardOnReturn: Bool = true
        var enablesReturnKeyAutomatically: Bool?
        var keyboardType: UIKeyboardType = .default
        var returnKeyType: UIReturnKeyType?
    }
    
    @Environment(\.font) var font
    @Environment(\.multilineTextAlignment) var multilineTextAlignment
        
    private var label: Label
    private var text: Binding<String>
    private var isEditing: Binding<Bool>
    private var configuration: _Configuration
    
    public var body: some View {
        ZStack(
            alignment: Alignment(
                horizontal: .init(from: multilineTextAlignment),
                vertical: .top
            )
        ) {
            if configuration.placeholder == nil {
                label
                    .font(configuration.uiFont.map(Font.init) ?? font)
                    .opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
                    .animation(nil)
            }
            
            _CocoaTextField<Label>(
                text: text,
                isEditing: isEditing,
                configuration:
                    configuration
            )
        }
        .background(ZeroSizeView().id(configuration.isFocused?.wrappedValue))
    }
}

fileprivate struct _CocoaTextField<Label: View>: UIViewRepresentable {
    typealias Configuration = CocoaTextField<Label>._Configuration
    typealias UIViewType = PlatformTextField
    
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
            
            DispatchQueue.main.async {
                self.text.wrappedValue = textField.text ?? ""
            }
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
            configuration.onCharactersChange(.init(currentText: textField.text ?? "", range: range, replacement: string))
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if configuration.dismissKeyboardOnReturn {
                textField.resignFirstResponder()
            }
            
            configuration.onCommit()
            
            return true
        }
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView = PlatformTextField()
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        uiView.delegate = context.coordinator
        
        if context.environment.isEnabled {
            DispatchQueue.main.async {
                if (configuration.isInitialFirstResponder ?? configuration.isFocused?.wrappedValue) ?? false {
                    uiView.becomeFirstResponder()
                }
            }
        }

        return uiView
    }
    
    func updateUIView(
        _ uiView: UIViewType,
        context: Context
    ) {
        context.coordinator.text = text
        context.coordinator.configuration = configuration
        
        uiView.isFirstResponderBinding = configuration.isFocused
        uiView.onDeleteBackward = configuration.onDeleteBackward
        uiView.textRect = configuration.textRect
        uiView.editingRect = configuration.editingRect
        uiView.clearButtonRect = configuration.clearButtonRect

        if let clearButtonImage = configuration.clearButtonImage, let clearButton = uiView.clearButton {
            if clearButton.image(for: .normal) !== clearButtonImage {
                clearButton.setImage(clearButtonImage, for: .normal)
                clearButton.setImage(clearButtonImage, for: .highlighted)
            }
        }

        setConfiguration: do {
            uiView.autocapitalizationType = configuration.autocapitalization ?? .sentences
            uiView.autocorrectionType = context.environment.disableAutocorrection.map({ $0 ? .no : .yes }) ?? .default
            uiView.borderStyle = configuration.borderStyle
            uiView.clearButtonMode = configuration.clearButtonMode ?? .never
            uiView.enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically ?? false
            uiView.font = try? configuration.uiFont ?? context.environment.font?.toAppKitOrUIKitFont() ?? uiView.font
            uiView.isSecureTextEntry = configuration.secureTextEntry ?? false
            uiView.isUserInteractionEnabled = context.environment.isEnabled
            uiView.keyboardType = configuration.keyboardType
            uiView.returnKeyType = configuration.returnKeyType ?? .default
            uiView.smartDashesType = configuration.smartDashesType ?? .default
            uiView.smartQuotesType = configuration.smartQuotesType ?? .default
            uiView.spellCheckingType = configuration.spellCheckingType ?? .default
            uiView.textAlignment = .init(context.environment.multilineTextAlignment)
            uiView.textColor = configuration.textColor
            uiView.textContentType = configuration.textContentType
            uiView.tintColor = context.environment.tintColor?.toUIColor()
            
            if let kerning = configuration.kerning {
                uiView.defaultTextAttributes.updateValue(kerning, forKey: .kern)
            }
        }
        
        setData: do {
            uiView.text = text.wrappedValue
            
            if let placeholder = configuration.placeholder {
                uiView.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .font: try? configuration.uiFont ?? context.environment.font?.toAppKitOrUIKitFont() ?? uiView.font,
                        .paragraphStyle: NSMutableParagraphStyle().then {
                            $0.alignment = .init(context.environment.multilineTextAlignment)
                        }
                    ]
                    .compactMapValues({ $0 })
                )
            } else {
                uiView.attributedPlaceholder = nil
                uiView.placeholder = nil
            }
        }
        
        uiView._SwiftUIX_inputView = configuration.inputView
        uiView._SwiftUIX_inputAccessoryView = configuration.inputAccessoryView

        if configuration.inputAssistantDisabled {
            #if os(iOS)
            uiView.inputAssistantItem.leadingBarButtonGroups = [UIBarButtonItemGroup()]
            uiView.inputAssistantItem.trailingBarButtonGroups = [UIBarButtonItemGroup()]
            #endif
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
    
    static func dismantleUIView(
        _ uiView: UIViewType,
        coordinator: Coordinator
    ) {
        if let isFocused = coordinator.configuration.isFocused {
            if isFocused.wrappedValue {
                isFocused.wrappedValue = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: text,
            isEditing: isEditing,
            configuration: configuration
        )
    }
}

// MARK: - Extensions

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
        self.configuration.placeholder = String(title)
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
    
    /// AddsUIText an action to perform when characters are changed in this text field.
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
    
    public func focused(_ isFocused: Binding<Bool>) -> Self {
        then({ $0.configuration.isFocused = isFocused })
    }
    
    public func focusRingType(_ focusRingType: FocusRingType) -> Self {
        then({ $0.configuration.focusRingType = focusRingType })
    }
}

extension CocoaTextField {
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.configuration.autocapitalization = autocapitalization })
    }
    
    public func borderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        then({ $0.configuration.borderStyle = borderStyle })
    }
    
    public func font(_ uiFont: UIFont?) -> Self {
        then({ $0.configuration.uiFont = uiFont })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.configuration.placeholder = placeholder })
    }
    
    public func foregroundColor(_ foregroundColor: Color?) -> Self {
        then({ $0.configuration.textColor = foregroundColor?.toUIColor() })
    }
    
    @_disfavoredOverload
    public func foregroundColor(_ foregroundColor: UIColor?) -> Self {
        then({ $0.configuration.textColor = foregroundColor })
    }
    
    @available(*, deprecated, renamed: "foregroundColor")
    public func textColor(_ foregroundColor: Color?) -> Self {
        then({ $0.configuration.textColor = foregroundColor?.toUIColor() })
    }
}

extension CocoaTextField {
    public func smartQuotesType(
        _ smartQuotesType: UITextSmartQuotesType
    ) -> Self {
        then({ $0.configuration.smartQuotesType = smartQuotesType })
    }
    
    public func smartDashesType(
        _ smartDashesType: UITextSmartDashesType
    ) -> Self {
        then({ $0.configuration.smartDashesType = smartDashesType })
    }
    
    public func spellCheckingType(
        _ spellCheckingType: UITextSpellCheckingType
    ) -> Self {
        then({ $0.configuration.spellCheckingType = spellCheckingType })
    }
}

extension CocoaTextField {
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.configuration.textContentType = textContentType })
    }
    
    public func secureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        then({ $0.configuration.secureTextEntry = isSecureTextEntry })
    }
    
    public func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
        then({ $0.configuration.clearButtonMode = clearButtonMode })
    }

    public func clearButtonImage(_ clearButtonImage: AppKitOrUIKitImage) -> Self {
        then({ $0.configuration.clearButtonImage = clearButtonImage })
    }
    
    // MARK: - Input Accessory -
    
    public func inputAccessoryView<InputAccessoryView: View>(_ view: InputAccessoryView) -> Self {
        then({ $0.configuration.inputAccessoryView = .init(view) })
    }
    
    public func inputView<InputView: View>(_ view: InputView) -> Self {
        then({ $0.configuration.inputView = .init(view) })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(@ViewBuilder _ view: () -> InputAccessoryView) -> Self {
        then({ $0.configuration.inputAccessoryView = .init(view()) })
    }
    
    @available(tvOS, unavailable)
    public func inputAssistantDisabled(_ isDisabled: Bool) -> some View {
        then({ $0.configuration.inputAssistantDisabled = isDisabled })
    }
    
    // MARK: Keyboard
    
    public func dismissKeyboardOnReturn(_ dismissKeyboardOnReturn: Bool) -> Self {
        then({ $0.configuration.dismissKeyboardOnReturn = dismissKeyboardOnReturn })
    }
    
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        then({ $0.configuration.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.configuration.keyboardType = keyboardType })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.configuration.returnKeyType = returnKeyType })
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

// MARK: - Auxiliary

private final class PlatformTextField: UITextField {
    var isFirstResponderBinding: Binding<Bool>?

    var onDeleteBackward: () -> Void = { }
    
    var textRect: CocoaTextField<AnyView>.Rect?
    var editingRect: CocoaTextField<AnyView>.Rect?
    var clearButtonRect: CocoaTextField<AnyView>.Rect?

    lazy var clearButton: UIButton? = value(forKeyPath: "_clearButton") as? UIButton

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        defer {
            if isFirstResponderBinding?.wrappedValue != isFirstResponder {
                isFirstResponderBinding?.wrappedValue = isFirstResponder
            }
        }

        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        defer {
            if isFirstResponderBinding?.wrappedValue != isFirstResponder {
                isFirstResponderBinding?.wrappedValue = isFirstResponder
            }
        }
        
       return super.resignFirstResponder()
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

extension PlatformTextField {
    fileprivate struct InputHostingView: View {
        let content: AnyView
        
        var body: some View {
            content
        }
    }
    
    var _SwiftUIX_inputView: AnyView? {
        get {
            return (inputView as? AppKitOrUIKitHostingView<InputHostingView>)?.rootView.content
        } set {
            if let newValue {
                if let hostingView = inputView as? AppKitOrUIKitHostingView<InputHostingView> {
                    hostingView.rootView = InputHostingView(content: newValue)
                } else {
                    let hostingView = AppKitOrUIKitHostingView(
                        rootView: InputHostingView(content: newValue)
                    )
                    
                    hostingView._disableSafeAreaInsets()
                    hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    inputView = hostingView
                }
            } else {
                inputView = nil
            }
        }
    }
}

extension PlatformTextField {
    fileprivate struct InputAccessoryHostingView: View {
        let content: AnyView
        
        var body: some View {
            content
        }
    }
    
    var _SwiftUIX_inputAccessoryView: AnyView? {
        get {
            return (inputAccessoryView as? AppKitOrUIKitHostingView<InputAccessoryHostingView>)?.rootView.content
        } set {
            if let newValue {
                if let hostingView = inputAccessoryView as? AppKitOrUIKitHostingView<InputAccessoryHostingView> {
                    hostingView.rootView = InputAccessoryHostingView(content: newValue)
                } else {
                    let hostingView = AppKitOrUIKitHostingView(
                        rootView: InputAccessoryHostingView(content: newValue)
                    )
                    
                    hostingView._disableSafeAreaInsets()
                    hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    inputAccessoryView = hostingView
                }
            } else {
                inputAccessoryView = nil
            }
        }
    }
}

#endif
