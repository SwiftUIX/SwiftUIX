//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct _TextViewConfiguration {
    public var _fixedSize: (Bool, Bool)? = nil
    
    var isConstant: Bool = false
    
    public var onEditingChanged: (Bool) -> Void = { _ in }
    public var onCommit: () -> Void = { }
    public var onDeleteBackward: () -> Void = { }
    
    var isInitialFirstResponder: Bool?
    var isFirstResponder: Bool?
    var isFocused: Binding<Bool>? = nil
    
    public var isEditable: Bool = true
    public var isSelectable: Bool = true
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    var autocapitalization: UITextAutocapitalizationType?
    #endif
    var cocoaFont: AppKitOrUIKitFont?
    var cocoaForegroundColor: AppKitOrUIKitColor?
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

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension TextView {
    public struct _CustomAppKitOrUIKitClassConfiguration {
        public typealias UpdateOperation<T> = (_ view: T, _ context: any _AppKitOrUIKitViewRepresentableContext) -> Void
        
        let `class`: AppKitOrUIKitTextView.Type
        let update: UpdateOperation<AppKitOrUIKitTextView>
        
        init(
            `class`: AppKitOrUIKitTextView.Type = _PlatformTextView<Label>.self
        ) {
            self.class = `class`
            self.update = { _, _ in }
        }
        
        init<T: AppKitOrUIKitTextView>(
            `class`: T.Type,
            update: @escaping UpdateOperation<T> = { _, _ in }
        ) {
            self.class = `class`
            self.update = { view, context in
                guard let view = view as? T else {
                    assertionFailure()
                    
                    return
                }
                
                update(view, context)
            }
        }
    }
}

public enum _TextViewDataBinding {
    public enum Value: Equatable {
        public enum Kind {
            case cocoaTextStorage
            case string
            case cocoaAttributedString
            case attributedString
        }
        
        case cocoaTextStorage(NSTextStorage)
        case string(String)
        case cocoaAttributedString(NSAttributedString)
        case attributedString(Any)
        
        var kind: Kind {
            switch self {
                case .cocoaTextStorage:
                    return .cocoaTextStorage
                case .string:
                    return .string
                case .cocoaAttributedString:
                    return .cocoaAttributedString
                case .attributedString:
                    return .attributedString
            }
        }
        
        var isAttributed: Bool {
            switch self {
                case .cocoaTextStorage:
                    return true
                case .string:
                    return false
                case .cocoaAttributedString:
                    return true
                case .attributedString:
                    return true
            }
        }
        
        var isEmpty: Bool {
            switch self {
                case .cocoaTextStorage(let storage):
                    return storage.string.isEmpty
                case .string(let value):
                    return value.isEmpty
                case .cocoaAttributedString(let value):
                    return value.length == 0
                case .attributedString(let value):
                    if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                        return NSAttributedString(value as! AttributedString).length == 0
                    } else {
                        assertionFailure()
                        
                        return true
                    }
            }
        }
        
        var cocoaTextStorageValue: NSTextStorage? {
            guard case .cocoaTextStorage(let value) = self else {
                return nil
            }
            
            return value
        }
        
        var stringValue: String? {
            guard case .string(let value) = self else {
                return nil
            }
            
            return value
        }
        
        var cocoaAttributedStringValue: NSAttributedString? {
            guard case .cocoaAttributedString(let value) = self else {
                return nil
            }
            
            return value
        }
        
        @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
        var attributedStringValue: AttributedString? {
            guard case .attributedString(let value) = self else {
                return nil
            }
            
            return .some(value as! AttributedString)
        }
        
        func toAttributedString(
            attributes: @autoclosure () -> [NSAttributedString.Key: Any]
        ) -> NSAttributedString {
            switch self {
                case .cocoaTextStorage(let storage):
                    assertionFailure()
                    
                    return storage.attributedSubstring(from: .init(location: 0, length: storage.length))
                case .string(let value):
                    return NSAttributedString(string: value, attributes: attributes())
                case .cocoaAttributedString(let value):
                    return value
                case .attributedString(let value):
                    if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                        return .init(value as! AttributedString)
                    } else {
                        assertionFailure()
                        
                        return NSAttributedString()
                    }
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            if let lhs = lhs.cocoaTextStorageValue, let rhs = rhs.cocoaTextStorageValue {
                return lhs === rhs
            } else if let lhs = lhs.stringValue, let rhs = rhs.stringValue {
                return lhs == rhs
            } else if let lhs = lhs.cocoaAttributedStringValue, let rhs = rhs.cocoaAttributedStringValue {
                return lhs === rhs || lhs.isEqual(to: rhs)
            } else {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    if let lhs = lhs.attributedStringValue, let rhs = rhs.attributedStringValue {
                        return lhs == rhs
                    }
                }
            }
            
            assertionFailure("unsupported")
            
            return false
        }
    }
    
    case cocoaTextStorage(NSTextStorage)
    case string(Binding<String>)
    case cocoaAttributedString(Binding<NSAttributedString>)
    case attributedString(Any)
    
    public var wrappedValue: Value {
        get {
            switch self {
                case .cocoaTextStorage(let value):
                    return .cocoaTextStorage(value)
                case .string(let binding):
                    return .string(binding.wrappedValue)
                case .cocoaAttributedString(let binding):
                    return .cocoaAttributedString(binding.wrappedValue)
                case .attributedString(let binding):
                    if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                        return .attributedString((binding as! Binding<AttributedString>).wrappedValue)
                    } else {
                        assertionFailure()
                        
                        return .attributedString(NSAttributedString())
                    }
            }
        } nonmutating set {
            switch (self, newValue) {
                case (.cocoaTextStorage(let value), .cocoaTextStorage(let newValue)):
                    assert(value === newValue)
                case (.string(let binding), .string(let newValue)):
                    binding.wrappedValue = newValue
                case (.cocoaAttributedString(let binding), .cocoaAttributedString(let newValue)):
                    guard !(binding.wrappedValue === newValue) else {
                        return
                    }
                    
                    binding.wrappedValue = newValue
                case (.attributedString(let binding), .attributedString(let newValue)):
                    if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                        (binding as! Binding<AttributedString>).wrappedValue = newValue as! AttributedString
                    } else {
                        assertionFailure()
                    }
                default:
                    assertionFailure()
            }
        }
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    public func _currentTextViewData(
        kind: _TextViewDataBinding.Value.Kind
    ) -> _TextViewDataBinding.Value {
        switch kind {
            case .cocoaTextStorage:
                guard let storage = _SwiftUIX_textStorage else {
                    assertionFailure()
                    
                    return .cocoaTextStorage(.init())
                }
                
                return .cocoaTextStorage(storage)
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
    
    public func setData(
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
                guard let storage = _SwiftUIX_textStorage else {
                    assertionFailure()
                    
                    return .cocoaTextStorage(.init())
                }
                
                return .cocoaTextStorage(storage)
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

    public func setData(
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
