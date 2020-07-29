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
    @_disfavoredOverload
    @available(iOS, introduced: 13.0, deprecated: 14.0)
    @available(macOS, introduced: 10.15, deprecated: 11.0)
    @available(tvOS, introduced: 13.0, deprecated: 14.0)
    @available(watchOS, introduced: 6.0, deprecated: 7.0)
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            onChange(of: value, perform: action)
        } else {
            modifier(OnChangeOfValue(initialValue: value, value: value, action: action))
        }
    }
}

#endif
