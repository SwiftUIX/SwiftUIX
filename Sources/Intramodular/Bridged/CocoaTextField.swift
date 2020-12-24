//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaTextField<Label: View>: CocoaView {
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
    private var shouldBeginEditing: Bool = true
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
    private var returnKeyType: UIReturnKeyType?
    private var textColor: UIColor?
    private var textContentType: UITextContentType?
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .init(from: multilineTextAlignment), vertical: .top)) {
            if placeholder == nil {
                label
                    .font(uiFont.map(Font.init) ?? font)
                    .opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
                    .animation(nil)
            }
            
            _CocoaTextField(
                text: text,
                shouldBeginEditing: shouldBeginEditing,
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
                placeholder: placeholder,
                returnKeyType: returnKeyType,
                textColor: textColor,
                textContentType: textContentType
            )
        }
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = UIHostingTextField
    
    @Binding var text: String
    
    var shouldBeginEditing: Bool
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
    var returnKeyType: UIReturnKeyType?
    var textColor: UIColor?
    var textContentType: UITextContentType?
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var base: _CocoaTextField
        
        init(base: _CocoaTextField) {
            self.base = base
        }
        
        /*public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         base.shouldBeginEditing
         }*/
        
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
        let uiView = UIHostingTextField()
        
        uiView.delegate = context.coordinator
        
        if let isFirstResponder = isInitialFirstResponder, isFirstResponder, context.environment.isEnabled {
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
        
        if let disableAutocorrection = context.environment.disableAutocorrection {
            uiView.autocorrectionType = disableAutocorrection ? .no : .yes
        } else {
            uiView.autocorrectionType = .default
        }

        uiView.font = uiFont ?? context.environment.font?.toUIFont()
                
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
        
        uiView.isUserInteractionEnabled = context.environment.isEnabled
        uiView.keyboardType = keyboardType
        
        if let placeholder = placeholder {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: uiFont ?? context.environment.font?.toUIFont() as Any,
                    .paragraphStyle: NSMutableParagraphStyle().then {
                        $0.alignment = .init(context.environment.multilineTextAlignment)
                    }
                ]
            )
        } else {
            uiView.attributedPlaceholder = nil
            uiView.placeholder = nil
        }
        
        if let returnKeyType = returnKeyType {
            uiView.returnKeyType = returnKeyType
        }
        
        if let textColor = textColor {
            uiView.textColor = textColor
        }
        
        if let textContentType = textContentType {
            uiView.textContentType = textContentType
        }
        
        uiView.text = text
        uiView.textAlignment = .init(context.environment.multilineTextAlignment)
        
        DispatchQueue.main.async {
            if let isFirstResponder = self.isFirstResponder, uiView.window != nil {
                if isFirstResponder && !uiView.isFirstResponder, context.environment.isEnabled {
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
    
    public func foregroundColor(_ foregroundColor: Color) -> Self {
        then({ $0.textColor = foregroundColor.toUIColor() })
    }
    
    public func foregroundColor(_ foregroundColor: UIColor) -> Self {
        then({ $0.textColor = foregroundColor })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.returnKeyType = returnKeyType })
    }
    
    @available(iOS, deprecated: 13.0, renamed: "foregroundColor(_:)")
    public func textColor(_ foregroundColor: Color) -> Self {
        then({ $0.textColor = foregroundColor.toUIColor() })
    }
    
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.textContentType = textContentType })
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
