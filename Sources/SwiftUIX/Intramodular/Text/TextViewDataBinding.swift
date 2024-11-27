//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public enum _TextViewDataBinding {
    @_documentation(visibility: internal)
public enum Value {
        @_documentation(visibility: internal)
        public enum Kind {
            case cocoaTextStorage
            case string
            case cocoaAttributedString
            case attributedString
        }
        
        case cocoaTextStorage(() -> NSTextStorage?)
        case string(String)
        case cocoaAttributedString(NSAttributedString)
        case attributedString(any Hashable)
        
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
                    return storage()?.string.isEmpty ?? true
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
            
            return value()
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
                case .cocoaTextStorage:
                    assertionFailure()
                    
                    return NSAttributedString()
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
    }
    
    case cocoaTextStorage(() -> NSTextStorage?)
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
                    assert(value() === newValue())
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

extension _TextViewDataBinding.Value: Equatable {
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

#endif

