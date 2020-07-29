//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that allows for inlined access to an `EnvironmentValues` key path.
public struct EnvironmentValueAccessView<Value, Content: View>: View {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let content: (Value) -> Content
    
    @usableFromInline
    @Environment var environmentValue: Value
    
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.keyPath = keyPath
        self.content = content
        
        self._environmentValue = .init(keyPath)
    }
    
    public var body: some View {
        content(environmentValue)
    }
}
