//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A type-erased wrapper for `ButtonStyle.`
public struct AnyButtonStyle: ButtonStyle {
    public let _makeBody: (Configuration) -> AnyView
    
    public init<V: View>(
        makeBody: @escaping (Configuration) -> V
    ) {
        self._makeBody = { makeBody($0).eraseToAnyView() }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        self._makeBody(configuration)
    }
}
