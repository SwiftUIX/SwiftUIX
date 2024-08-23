//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

/// A control that displays an editable text interface.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@_documentation(visibility: internal)
public struct TextView<Label: View>: View {
    public typealias _Configuration = _TextViewConfiguration
    
    @Environment(\.font) private var font
    @Environment(\.preferredMaximumLayoutWidth) private var preferredMaximumLayoutWidth
    
    var label: Label
    var data: _TextViewDataBinding
    var textViewConfiguration: _TextViewConfiguration
    var customAppKitOrUIKitClassConfiguration = _CustomAppKitOrUIKitClassConfiguration()
    
    @State var representableUpdater = EmptyObservableObject()
    
    public var body: some View {
        ZStack(alignment: .top) {
            if let _fixedSize = textViewConfiguration._fixedSize {
                switch _fixedSize.value {
                    case (false, false):
                        XSpacer()
                    default:
                        EmptyView() // TODO: Implement
                }
            }
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                if data.wrappedValue.isEmpty {
                    label
                        .font(textViewConfiguration.cocoaFont.map(Font.init) ?? font)
                        .foregroundColor(Color(textViewConfiguration.placeholderColor ?? .placeholderText))
                        .animation(.none)
                        .padding(textViewConfiguration.textContainerInsets)
                }
                
                _TextView<Label>(
                    updater: representableUpdater,
                    data: data,
                    textViewConfiguration: textViewConfiguration,
                    customAppKitOrUIKitClassConfiguration: customAppKitOrUIKitClassConfiguration
                )
            }
        }
        ._geometryGroup(.if(.available))
    }
}

// MARK: - Initializers

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView where Label == EmptyView {
    @_spi(Internal)
    public init(
        data: _TextViewDataBinding,
        configuration: _Configuration
    ) {
        self.label = EmptyView()
        self.data = data
        self.textViewConfiguration = configuration
    }

    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self.data = .string(text)
        self.textViewConfiguration = .init(
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
        text: Binding<NSMutableAttributedString>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = EmptyView()
        self.data = .cocoaAttributedString(
            Binding(
                get: {
                    text.wrappedValue
                },
                set: { newValue in
                    if let newValue = newValue as? NSMutableAttributedString {
                        text.wrappedValue = newValue
                    } else {
                        text.wrappedValue = newValue.mutableCopy() as! NSMutableAttributedString
                    }
                }
            )
        )
        self.textViewConfiguration = .init(
            isConstant: false,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
    
    public init(
        _ text: String
    ) {
        self.label = EmptyView()
        self.data = .string(.constant(text))
        self.textViewConfiguration = .init(
            isConstant: true,
            onEditingChanged: { _ in },
            onCommit: { }
        )
    }
    
    public init(
        _ text: NSAttributedString
    ) {
        self.label = EmptyView()
        self.data = .cocoaAttributedString(.constant(text))
        self.textViewConfiguration = .init(
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
        self.data = .attributedString(Binding<AttributedString>.constant(text))
        self.textViewConfiguration = .init(
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
        self.label = Text(title)
        self.data = .string(text)
        self.textViewConfiguration = .init(
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

// MARK: - Modifiers



// MARK: - Deprecated

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    @available(*, deprecated)
    public func isFirstResponder(
        _ isFirstResponder: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.isFirstResponder = isFirstResponder })
    }
    
    @available(*, deprecated, renamed: "TextView.editable(_:)")
    public func isEditable(
        _ isEditable: Bool
    ) -> Self {
        self.editable(isEditable)
    }
}

#endif
