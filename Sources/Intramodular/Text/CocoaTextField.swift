//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaTextField<Label: View>: View {
    private var label: Label
    
    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    private var font: UIFont?
    private var placeholder: String?
    private var kerning: CGFloat?
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            if text.wrappedValue.isEmpty {
                label
            }
            
            _CocoaTextField(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                font: font,
                placeholder: placeholder,
                kerning: kerning
            )
        }
    }
    
    public func font(_ font: UIFont) -> Self {
        then({ $0.font = font })
    }
    
    public func kerning(_ kerning: CGFloat) -> Self {
        then({ $0.kerning = kerning })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = UITextField
    
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    var font: UIFont?
    var placeholder: String?
    var kerning: CGFloat?
    
    init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        font: UIFont?,
        placeholder: String?,
        kerning: CGFloat?
    ) {
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.font = font
        self.placeholder = placeholder
        self.kerning = kerning
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var base: _CocoaTextField
        
        init(base: _CocoaTextField) {
            self.base = base
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            base.text = textField.text ?? ""
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            base.onEditingChanged(false)
            base.onCommit()
        }
    }
    
    var isFirstResponder: Bool = false
    
    public func makeUIView(context: Context) -> UIViewType {
        let textField = UITextField(frame: .zero)
        
        textField.delegate = context.coordinator
        textField.configure(for: self)
        
        return textField
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.configure(for: self)
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
    
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
}

// MARK: - Helpers -

extension UITextField {
    public func configure(for textField: _CocoaTextField) {
        font = textField.font
        
        if let kerning = textField.kerning {
            defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        placeholder = textField.placeholder
        text = textField.text
    }
}

#endif
