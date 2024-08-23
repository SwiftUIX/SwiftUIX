//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct _TypeToViewTraitKeyAdaptor<T>: _ViewTraitKey {
    public typealias Value = T?
    
    public static var defaultValue: T? {
        nil
    }
}

extension View {
    public func _SwiftUIX_trait<Value>(
        _: Value.Type,
        _ value: Value
    ) -> some View {
        return self._trait(_TypeToViewTraitKeyAdaptor<Value>.self, value)
    }

    @available(*, deprecated)
    public func trait<Value>(
        _: Value.Type,
        _ value: Value
    ) -> some View {
        return self._trait(_TypeToViewTraitKeyAdaptor<Value>.self, value)
    }
}
