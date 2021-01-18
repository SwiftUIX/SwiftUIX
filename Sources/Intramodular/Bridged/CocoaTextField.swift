//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
public struct CocoaTextField<Label: View>: CocoaView {
    public struct CharactersChange {
        public let range: NSRange
        public let replacement: String
    }
    
    struct _Configuration {
        var onEditingChanged: (Bool) -> Void
        var onCommit: () -> Void
        var onDeleteBackward: () -> Void = { }
        var onCharactersChange: (CharactersChange) -> Bool = { _ in true }
        
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
    private var configuration: _Configuration
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .init(from: multilineTextAlignment), vertical: .top)) {
            if configuration.placeholder == nil {
                label
                    .font(configuration.uiFont.map(Font.init) ?? font)
                    .opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
                    .animation(nil)
            }
            
            _CocoaTextField<Label>(text: text, configuration: configuration)
        }
    }
}

struct _CocoaTextField<Label: View>: UIViewRepresentable {
    typealias Configuration = CocoaTextField<Label>._Configuration
    typealias UIViewType = UIHostingTextField
    
    let text: Binding<String>
    let configuration: Configuration
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var configuration: Configuration
        
        init(text: Binding<String>, configuration: Configuration) {
            self.text = text
            self.configuration = configuration
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            configuration.onEditingChanged(true)
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            guard textField.markedTextRange == nil else {
                return
            }
            
            text.wrappedValue = textField.text ?? ""
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            configuration.onEditingChanged(false)
            configuration.onCommit()
        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            configuration.onCharactersChange(.init(range: range, replacement: string))
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            
            return true
        }
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let uiView = UIHostingTextField()
        
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
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
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
        .init(text: text, configuration: configuration)
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
        self.configuration = .init(onEditingChanged: onEditingChanged, onCommit: onCommit)
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

#endif
