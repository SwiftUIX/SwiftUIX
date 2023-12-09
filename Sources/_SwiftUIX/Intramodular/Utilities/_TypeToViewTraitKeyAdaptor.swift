//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _TypeToViewTraitKeyAdaptor<T>: _ViewTraitKey {
    public typealias Value = T?
    
    public static var defaultValue: T? {
        nil
    }
}

extension View {
    public func trait<Value>(
        _: Value.Type,
        _ value: Value
    ) -> some View {
        return self._trait(_TypeToViewTraitKeyAdaptor<Value>.self, value)
    }
}
