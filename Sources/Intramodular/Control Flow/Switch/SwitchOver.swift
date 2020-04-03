//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import CasePaths

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
       
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View, Value>(
        _ predicate: CasePathPredicate<Data, Value>,
        @ViewBuilder content: (Value) -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> {
        return .init(
            comparator: comparator,
            predicate: predicate,
            content: content
        )
    }
    
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View, Value>(
        _ predicate: CasePathPredicate<Data, Value>,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseFirstView<Data, Content> {
        return .init(
            comparator: comparator,
            predicate: predicate,
            content: content
        )
    }
}

import CasePaths
public struct CasePathPredicate<Root, Value> {
    private var path: CasePath<Root, Value>
    
    var boolPredicate: (Root) -> Bool { { self.valuePredicate($0) != nil } }
    
    var valuePredicate: (Root) -> Value? { path.extract }
    
    public static func `if`(_ path: CasePath<Root, Value>) -> Self {
        .init(path: path)
    }
}
