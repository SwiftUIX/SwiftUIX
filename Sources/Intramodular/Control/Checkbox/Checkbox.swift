//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A checkbox control.
public struct Checkbox<Label: View>: View {
    @Environment(\._checkboxStyle) var _checkboxStyle
    
    /// A view that describes the effect of toggling `isOn`.
    public let label: Label
    
    /// Whether or not `self` is currently "on" or "off".
    public let isOn: Binding<Bool>
    
    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.label = label()
    }
    
    public var body: some View {
        Button(toggle: isOn) {
            _checkboxStyle.makeBodyImpl(.init(label: label.eraseToAnyView(), isSelected: isOn.wrappedValue))
        }
    }
}

extension Checkbox where Label == EmptyView {
    public init(isOn: Binding<Bool>) {
        self.isOn = isOn
        self.label = EmptyView()
    }
}

// MARK: - Auxiliary Implementation -

public struct DefaultCheckboxStyle: CheckboxStyle {
    public init() {
        
    }
    
    public func makeBody(configuration: CheckboxStyleConfiguration) -> some View {
        HStack {
            configuration.label
            
            configuration.isSelected
                ? Image(systemName: .checkmarkSquareFill)
                : Image(systemName: .checkmarkSquare)
        }
    }
}

public struct CircularCheckboxStyle: CheckboxStyle {
    public init() {
        
    }
    
    public func makeBody(configuration: CheckboxStyleConfiguration) -> some View {
        HStack {
            configuration.label
            
            configuration.isSelected
                ? Image(systemName: .checkmarkCircleFill)
                : Image(systemName: .checkmarkCircle)
        }
    }
}
