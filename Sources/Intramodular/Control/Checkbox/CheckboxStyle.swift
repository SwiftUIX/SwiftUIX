//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The properties of a `Button` instance being created.
public struct CheckboxStyleConfiguration {
    public typealias Label = AnyView
    
    /// A view that describes the effect of toggling `isOn`.
    public let label: Label
    
    /// Whether or not the checkbox is currently selected by the user.
    public let isSelected: Bool
}

public protocol CheckboxStyle {
    associatedtype Body: View
    
    func makeBody(configuration: CheckboxStyleConfiguration) -> Body
}

// MARK: - API -

extension View {
    @available(OSX 10.16, *)
    public func checkboxStyle<S: CheckboxStyle>(_ style: S) -> some View {
        environment(\._checkboxStyle, .init(style))
    }
}

// MARK: - Auxiliary Implementation -

@available(OSX 10.16, *)
struct _CheckboxStyle {
    var makeBodyImpl: (CheckboxStyleConfiguration) -> AnyView
    
    init<Style: CheckboxStyle>(_ style: Style) {
        self.makeBodyImpl = { style.makeBody(configuration: $0).eraseToAnyView() }
    }
}

@available(OSX 10.16, *)
extension _CheckboxStyle {
    @available(OSX 10.16, *)
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        @available(OSX 10.16, *)
        static let defaultValue = _CheckboxStyle(DefaultCheckboxStyle())
    }
}

extension EnvironmentValues {
    @available(OSX 10.16, *)
    var _checkboxStyle: _CheckboxStyle {
        get {
            self[_CheckboxStyle.EnvironmentKey.self]
        } set {
            self[_CheckboxStyle.EnvironmentKey.self] = newValue
        }
    }
}
