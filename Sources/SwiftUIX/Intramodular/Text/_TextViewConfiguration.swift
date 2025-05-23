//
// Copyright (c) Vatsal Manot
//

import _SwiftUIX
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public struct _TextViewConfiguration: Hashable, DynamicProperty {
    @_SwiftUIX_RenderIgnored var customAppKitOrUIKitClassConfiguration: _AnyTextView._CustomAppKitOrUIKitClassConfiguration?

    public var _fixedSize: _SwiftUIX_FixedSizeInfo? = nil
    public var isContentCopyable: Bool = true
    public var isConstant: Bool = false
    
    @_SwiftUIX_RenderIgnored public var onEditingChanged: (Bool) -> Void = { _ in }
    @_SwiftUIX_RenderIgnored public var onCommit: (() -> Void)?
    @_SwiftUIX_RenderIgnored public var onDeleteBackward: () -> Void = { }
    
    var isInitialFirstResponder: Bool?
    var isFirstResponder: Bool?
    @_SwiftUIX_HashableBinding.Optional var isFocused: Binding<Bool>? = nil
    
    public var isEditable: Bool = true
    public var isSelectable: Bool = true
        
    @_SwiftUIX_HashableEdgeInsets
    var textContainerInsets: EdgeInsets = EdgeInsets.zero
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var autocapitalization: UITextAutocapitalizationType?
    #endif
    var automaticQuoteSubstitutionDisabled: Bool?
    @_spi(Internal)
    public var cocoaFont: AppKitOrUIKitFont?
    @_spi(Internal)
    public var cocoaForegroundColor: AppKitOrUIKitColor?
    var tintColor: AppKitOrUIKitColor?
    var kerning: CGFloat?
    var linkForegroundColor: AppKitOrUIKitColor?
    var placeholderColor: AppKitOrUIKitColor?
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var textContentType: UITextContentType?
    #endif
    var dismissKeyboardOnReturn: Bool = false
    var enablesReturnKeyAutomatically: Bool?
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var keyboardType: UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType?
    #endif
    
    @_SwiftUIX_RenderIgnored public var _dropDelegate: Any?
    
    #if !os(tvOS)
    @available(iOS 16.0, macOS 13.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var dropDelegate: (any _SwiftUIX_DropDelegate<_SwiftUIX_DropInfo>)? {
        get {
            _dropDelegate.map({ $0 as! (any _SwiftUIX_DropDelegate<_SwiftUIX_DropInfo>) })
        } set {
            _dropDelegate = newValue
        }
    }
    #endif
    
    var requiresAttributedText: Bool {
        kerning != nil
    }
    
    public init(
        isConstant: Bool = false,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.isConstant = isConstant
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    public func _currentTextViewData(
        kind: _TextViewDataBinding.Value.Kind
    ) -> _TextViewDataBinding.Value {
        switch kind {
            case .cocoaTextStorage:
                guard let textStorage = _SwiftUIX_textStorage else {
                    assertionFailure()
                    
                    return .cocoaTextStorage({ .init() })
                }
                
                return .cocoaTextStorage({ [weak textStorage] in
                    textStorage
                })
            case .string:
                return .string(text ?? (attributedText?.string ?? ""))
            case .cocoaAttributedString:
                return .cocoaAttributedString(attributedText)
            case .attributedString:
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    if let attributedText {
                        return .attributedString(AttributedString(attributedText))
                    } else {
                        assertionFailure()
                        
                        return .attributedString(AttributedString())
                    }
                } else {
                    assertionFailure()
                    
                    return .attributedString(NSAttributedString())
                }
        }
    }
    
    public func setDataValue(
        _ data: _TextViewDataBinding.Value
    ) {
        switch data {
            case .cocoaTextStorage:
                assertionFailure("unsupported")
            case .string(let value):
                self.text = value
            case .cocoaAttributedString(let value):
                self.attributedText = value
            case .attributedString:
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    guard let value = data.attributedStringValue else {
                        assertionFailure()
                        
                        return
                    }
                    
                    self.attributedText = NSAttributedString(value)
                } else {
                    assertionFailure()
                }
        }
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    public func _currentTextViewData(
        kind: _TextViewDataBinding.Value.Kind
    ) -> _TextViewDataBinding.Value {
        switch kind {
            case .cocoaTextStorage:
                guard let textStorage = _SwiftUIX_textStorage else {
                    assertionFailure()
                    
                    return .cocoaTextStorage({ nil })
                }
                
                return .cocoaTextStorage({ [weak textStorage] in
                    textStorage
                })
            case .string:
                return .string(string)
            case .cocoaAttributedString:
                return .cocoaAttributedString(attributedString())
            case .attributedString:
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    return .attributedString(AttributedString(attributedString()))
                } else {
                    assertionFailure()
                    
                    return .attributedString(NSAttributedString())
                }
        }
    }
    
    public func setDataValue(
        _ data: _TextViewDataBinding.Value
    ) {
        switch data {
            case .cocoaTextStorage:
                assertionFailure("unsupported")
            case .string(let value):
                self.string = value
            case .cocoaAttributedString(let string):
                guard let textStorage else {
                    assertionFailure()
                    
                    return
                }
                
                textStorage.setAttributedString(string)
            case .attributedString(let value):
                guard let textStorage else {
                    assertionFailure()
                    
                    return
                }
                
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    let value = value as! AttributedString
                    
                    textStorage.setAttributedString(NSAttributedString(value))
                } else {
                    assertionFailure()
                }
        }
    }
}
#endif

#endif

extension EnvironmentValues {
    private struct LineBreakModeKey: EnvironmentKey {
        static let defaultValue: NSLineBreakMode = .byWordWrapping
    }
    
    public var lineBreakMode: NSLineBreakMode {
        get {
            self[LineBreakModeKey.self]
        } set {
            self[LineBreakModeKey.self] = newValue
        }
    }
}

extension EnvironmentValues {
    private struct AdjustsFontSizeToFitWidthKey: EnvironmentKey {
        static let defaultValue: Bool = false
    }
    
    public var adjustsFontSizeToFitWidth: Bool {
        get {
            self[AdjustsFontSizeToFitWidthKey.self]
        } set {
            self[AdjustsFontSizeToFitWidthKey.self] = newValue
        }
    }
}

// MARK: - API

extension View {
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> some View {
        environment(\.adjustsFontSizeToFitWidth, adjustsFontSizeToFitWidth)
    }
    
    public func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> some View {
        environment(\.lineBreakMode, lineBreakMode)
    }
}

// MARK: - Internal

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension EnvironmentValues {
    public struct _TextViewConfigurationMutationKey: EnvironmentKey {
        public typealias Value = (inout _TextViewConfiguration) -> Void
        
        public static let defaultValue: Value = { _ in }
    }
    
    public var _textViewConfigurationMutation: _TextViewConfigurationMutationKey.Value {
        get {
            self[_TextViewConfigurationMutationKey.self]
        } set {
            self[_TextViewConfigurationMutationKey.self] = newValue
        }
    }
}

#endif
