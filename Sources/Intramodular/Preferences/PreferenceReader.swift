//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view whose child is defined as a function of a preference value read from within the child.
public struct PreferenceReader<Key: SwiftUI.PreferenceKey, Content: View>: View where Key.Value: Equatable {
    private let content: (Key.Value) -> Content
    
    @State var value: Key.Value?
    
    public init(
        _ keyType: Key.Type = Key.self,
        @ViewBuilder content: @escaping (Key.Value) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(value ?? Key.defaultValue)
            .onPreferenceChange(Key.self) {
                value = $0
            }
    }
}
