//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view capable of capturing and managing errors.
public struct ErrorContextView<Content: View>: View {
    private let content: Content
    
    @State var errorContext = ErrorContext()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content.onPreferenceChange(ErrorContextPreferenceKey.self) {
            self.errorContext = $0
        }
        .preference(key: ErrorContextPreferenceKey.self, value: .init())
        .errorContext(errorContext)
    }
}

extension View {
    public func manageErrorContext() -> ErrorContextView<Self> {
        .init(content: { self })
    }
}
