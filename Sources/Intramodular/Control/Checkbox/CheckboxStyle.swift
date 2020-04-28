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
    public func checkboxStyle<S: CheckboxStyle>(_ style: S) -> some View {
        environment(\._checkboxStyle, .init(style))
    }
}

// MARK: - Auxiliary Implementation -

struct _CheckboxStyle {
    var makeBodyImpl: (CheckboxStyleConfiguration) -> AnyView
    
    init<Style: CheckboxStyle>(_ style: Style) {
        self.makeBodyImpl = { style.makeBody(configuration: $0).eraseToAnyView() }
    }
}

extension _CheckboxStyle {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = _CheckboxStyle(DefaultCheckboxStyle())
    }
}

extension EnvironmentValues {
    var _checkboxStyle: _CheckboxStyle {
        get {
            self[_CheckboxStyle.EnvironmentKey]
        } set {
            self[_CheckboxStyle.EnvironmentKey] = newValue
        }
    }
}
