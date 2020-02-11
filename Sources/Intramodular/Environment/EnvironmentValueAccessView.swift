//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct EnvironmentValueAccessView<EnvironmentValue, Content: View>: View {
    private let keyPath: KeyPath<EnvironmentValues, EnvironmentValue>
    private let content: (EnvironmentValue) -> Content
    
    @Environment var environmentValue: EnvironmentValue
    
    public init(
        _ keyPath: KeyPath<EnvironmentValues, EnvironmentValue>,
        @ViewBuilder content: @escaping (EnvironmentValue) -> Content
    ) {
        self.keyPath = keyPath
        self.content = content
        
        self._environmentValue = .init(keyPath)
    }
    
    public var body: some View {
        content(environmentValue)
    }
}
