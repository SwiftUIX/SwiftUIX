//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.3)

import Swift
import SwiftUI

struct OnChangeOfValue<V: Equatable>: ViewModifier {
    @State var initialValue: V
    
    let value: V
    let action: (V) -> Void
    
    func body(content: Content) -> some View {
        if initialValue != value {
            DispatchQueue.main.async {
                initialValue = value
                
                action(value)
            }
        }
        
        return content
    }
}

extension View {
    @ViewBuilder
    public func _backport_onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        modifier(OnChangeOfValue(initialValue: value, value: value, action: action))
    }
    
    @_disfavoredOverload
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            onChange(of: value, perform: action)
        } else {
            _backport_onChange(of: value, perform: action)
        }
    }
}

#endif
