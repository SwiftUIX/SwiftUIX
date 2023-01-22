//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view representing the start of a `switch` control flow.
public struct SwitchOver<Data>: View {
    public let comparator: Data
    
    public init(_ comparator: Data) {
        self.comparator = comparator
    }
    
    public var body: some View {
        return EmptyView()
    }
}

// MARK: - Extensions -

extension SwitchOver {
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> {
        return .init(
            comparator: comparator,
            predicate: predicate,
            content: content
        )
    }
    
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> where Data: Equatable {
        return .init(
            comparator: comparator,
            comparate: comparate,
            content: content
        )
    }
}
