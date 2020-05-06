//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaTextField<Label: View>: CocoaView {
    private var label: Label
    
    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    private var onDeleteBackward: () -> Void = { }
    
    private var isInitialFirstResponder: Bool?
    private var isFirstResponder: Bool?
    
    private var autocapitalization: UITextAutocapitalizationType?
    private var borderStyle: UITextField.BorderStyle = .none
    private var uiFont: UIFont?
    private var inputAccessoryView: AnyView?
    private var inputView: AnyView?
    private var kerning: CGFloat?
    private var keyboardType: UIKeyboardType = .default
    private var placeholder: String?
    
    @Environment(\.font) var font
    
    public var body: some View {
        return ZStack(alignment: .topLeading) {
            if placeholder == nil {
                label
                    .font(uiFont.map(Font.init) ?? font)
                    .opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
                    .animation(nil)
            }
            
            _CocoaTextField(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                onDeleteBackward: onDeleteBackward,
                isInitialFirstResponder: isInitialFirstResponder,
                isFirstResponder: isFirstResponder,
                autocapitalization: autocapitalization,
                borderStyle: borderStyle,
                uiFont: uiFont,
                inputAccessoryView: inputAccessoryView,
                inputView: inputView,
                kerning: kerning,
                keyboardType: keyboardType,
                placeholder: placeholder
            )
        }
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = _UITextField
    
    @Environment(\.font) var font
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.multilineTextAlignment) var multilineTextAlignment: TextAlignment
    
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    var onDeleteBackward: () -> Void
    var isInitialFirstResponder: Bool?
    var isFirstResponder: Bool?
    var autocapitalization: UITextAutocapitalizationType?
    var borderStyle: UITextField.BorderStyle
    var uiFont: UIFont?
    var inputAccessoryView: AnyView?
    var inputView: AnyView?
    var kerning: CGFloat?
    var keyboardType: UIKeyboardType
    var placeholder: String?
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var base: _CocoaTextField
        
        init(base: _CocoaTextField) {
            self.base = base
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            base.onEditingChanged(true)
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            base.text = textField.text ?? ""
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            base.onEditingChanged(false)
            base.onCommit()
        }
        
        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            
            return true
        }
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = _UITextField()
        
        uiView.delegate = context.coordinator
        
        if let isFirstResponder = isInitialFirstResponder, isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.onDeleteBackward = onDeleteBackward
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        if let autocapitalization = autocapitalization {
            uiView.autocapitalizationType = autocapitalization
        }
        
        uiView.borderStyle = borderStyle
        uiView.font = uiFont ?? font?.toUIFont()
        
        if let kerning = kerning {
            uiView.defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        if let inputAccessoryView = inputAccessoryView {
            if let _inputAccessoryView = uiView.inputAccessoryView as? UIHostingView<AnyView> {
                _inputAccessoryView.rootView = inputAccessoryView
            } else {
                uiView.inputAccessoryView = UIHostingView(rootView: inputAccessoryView)
                uiView.inputAccessoryView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            uiView.inputAccessoryView = nil
        }
        
        if let inputView = inputView {
            if let _inputView = uiView.inputView as? UIHostingView<AnyView> {
                _inputView.rootView = inputView
            } else {
                uiView.inputView = UIHostingView(rootView: inputView)
                uiView.inputView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            uiView.inputView = nil
        }
        
        uiView.isUserInteractionEnabled = isEnabled
        uiView.keyboardType = keyboardType
        
        if let placeholder = placeholder {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: font as Any,
                    .paragraphStyle: NSMutableParagraphStyle().then {
                        $0.alignment = .init(multilineTextAlignment)
                    }
                ]
            )
        } else {
            uiView.attributedPlaceholder = nil
            uiView.placeholder = nil
        }
        
        uiView.text = text
        uiView.textAlignment = .init(multilineTextAlignment)
        
        DispatchQueue.main.async {
            if let isFirstResponder = self.isFirstResponder, uiView.window != nil {
                if isFirstResponder && !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                } else if !isFirstResponder && uiView.isFirstResponder {
                    uiView.resignFirstResponder()
                }
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
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
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.label = label()
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

extension CocoaTextField {
    public func onDeleteBackward(perform action: @escaping () -> Void) -> Self {
        then({ $0.onDeleteBackward = action })
    }
}

extension CocoaTextField {
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.isInitialFirstResponder = isInitialFirstResponder })
    }
    
    public func isFirstResponder(_ isFirstResponder: Bool) -> Self {
        then({ $0.isFirstResponder = isFirstResponder })
    }
}

extension CocoaTextField {
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.autocapitalization = autocapitalization })
    }
    
    public func borderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        then({ $0.borderStyle = borderStyle })
    }
    
    public func font(_ uiFont: UIFont) -> Self {
        then({ $0.uiFont = uiFont })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(_ view: InputAccessoryView) -> Self {
        then({ $0.inputAccessoryView = .init(view) })
    }
    
    public func inputView<InputView: View>(_ view: InputView) -> Self {
        then({ $0.inputView = .init(view) })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(@ViewBuilder _ view: () -> InputAccessoryView) -> Self {
        then({ $0.inputAccessoryView = .init(view()) })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
}

extension CocoaTextField where Label == Text {
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then {
            $0.label = Text(placeholder).kerning(kerning)
            $0.placeholder = placeholder
        }
    }
}

#endif
