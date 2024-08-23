//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
@_documentation(visibility: internal)
public struct PreferenceValue<Key: PreferenceKey>: View {
    public let key: Key.Type
    public let value: Key.Value
    
    public init(key: Key.Type, value: Key.Value) {
        self.key = key
        self.value = value
    }
    
    public var body: some View {
        ZeroSizeView()
            .preference(key: key, value: value)
    }
}

@frozen
@_documentation(visibility: internal)
public struct TransformPreferenceValue<Key: PreferenceKey>: View {
    public let key: Key.Type
    public let callback: (inout Key.Value) -> Void
    
    public init(_ key: Key.Type, callback: @escaping (inout Key.Value) -> Void) {
        self.key = key
        self.callback = callback
    }
    
    public var body: some View {
        ZeroSizeView()
            .transformPreference(key, callback)
    }
}
