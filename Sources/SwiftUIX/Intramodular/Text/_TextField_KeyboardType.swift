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

/// The keyboard type to be displayed.
@_documentation(visibility: internal)
public enum _TextField_KeyboardType {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension UIKeyboardType {
    public init(from keyboardType: _TextField_KeyboardType) {
        switch keyboardType {
            case .default:
                self = .default
            case .asciiCapable:
                self = .asciiCapable
            case .numbersAndPunctuation:
                self = .numbersAndPunctuation
            case .URL:
                self = .URL
            case .numberPad:
                self = .numberPad
            case .phonePad:
                self = .phonePad
            case .namePhonePad:
                self = .namePhonePad
            case .emailAddress:
                self = .emailAddress
            case .decimalPad:
                self = .decimalPad
            case .twitter:
                self = .twitter
            case .webSearch:
                self = .webSearch
            case .asciiCapableNumberPad:
                self = .asciiCapable
        }
    }
}
#else
extension View {
    public func keyboardType(
        _ keyboardType: _TextField_KeyboardType
    ) -> some View {
        environment(\._textField_keyboardType, keyboardType)
    }
}
#endif

// MARK: - Auxiliary

extension EnvironmentValues {
    struct _TextField_KeyboardTypeKey: EnvironmentKey {
        static let defaultValue: _TextField_KeyboardType = .default
    }
    
    @_spi(Internal)
    public var _textField_keyboardType: _TextField_KeyboardType {
        get {
            self[_TextField_KeyboardTypeKey.self]
        } set {
            self[_TextField_KeyboardTypeKey.self] = newValue
        }
    }
}

#endif
