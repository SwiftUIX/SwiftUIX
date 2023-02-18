//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view representing a `case` statement in a `switch` control flow.
public protocol SwitchOverCaseView: ControlFlowView {
    /// The type of data being compared in the control flow.
    associatedtype Data
    
    /// The data being compared against in the control flow.
    var comparator: Data { get }
    
    /// The predicate being used for matching in the control flow.
    var predicate: (Data) -> Bool { get }
    
    /// Whether `self` represents a match in the control flow.
    var isAMatch: Bool { get }
    
    /// Whether any cases prior to `self` represent a match in the control flow.
    var hasMatchedPreviously: Bool? { get }
}

/// A view representing first `case` statement in a `switch` control flow.
public struct SwitchOverCaseFirstView<Data, Content: View>: SwitchOverCaseView {
    public let comparator: Data
    public let predicate: (Data) -> Bool
    
    public let body: Content?
    
    public var isAMatch: Bool {
        return predicate(comparator)
    }
    
    public var hasMatchedPreviously: Bool? {
        return nil
    }
    
    public init(
        comparator: Data,
        predicate: @escaping (Data) -> Bool,
        content: () -> Content
    ) {
        self.comparator = comparator
        self.predicate = predicate
        
        body = predicate(comparator) ? content() : nil
    }
}

extension SwitchOverCaseFirstView where Data: Equatable {
    public init(
        comparator: Data,
        comparate: Data,
        content: () -> Content
    )  {
        self.init(
            comparator: comparator,
            predicate: { $0 == comparate },
            content: content
        )
    }
}

/// A view representing a noninitial `case` statement in a `switch` control flow.
public struct SwitchOverCaseNextView<PreviousCase: SwitchOverCaseView, Content: View>: SwitchOverCaseView {
    public typealias Data = PreviousCase.Data
    
    public let previous: PreviousCase
    public let predicate: (Data) -> Bool
    public let body: _ConditionalContent<PreviousCase, Content?>
    
    public var comparator: Data {
        return previous.comparator
    }
    
    public var isAMatch: Bool {
        return predicate(comparator)
    }
    
    public var hasMatchedPreviously: Bool? {
        if previous.isAMatch {
            return true
        } else {
            return previous.hasMatchedPreviously
        }
    }
    
    public init(
        previous: PreviousCase,
        predicate: @escaping (Data) -> Bool,
        content: () -> Content
    ) {
        self.previous = previous
        self.predicate = predicate
        
        if (previous.isAMatch || (previous.hasMatchedPreviously ?? false)) {
            self.body = ViewBuilder.buildEither(first: previous)
        } else if predicate(previous.comparator) {
            self.body = ViewBuilder.buildEither(second: content())
        } else {
            self.body = ViewBuilder.buildEither(second: nil)
        }
    }
}

extension SwitchOverCaseNextView where Data: Equatable {
    public init(
        previous: PreviousCase,
        comparate: Data,
        content: () -> Content
    )  {
        self.init(
            previous: previous,
            predicate: { $0 == comparate },
            content: content
        )
    }
}

/// A view representing a `default` statement in a `switch` control flow.
public struct SwitchOverCaseDefaultView<PreviousCase: SwitchOverCaseView, Content: View>: View {
    public typealias Data = PreviousCase.Data
    
    public let previous: PreviousCase
    public let body: _ConditionalContent<PreviousCase, Content>
    
    public init(previous: PreviousCase, content: () -> Content) {
        self.previous = previous
        
        if previous.isAMatch || (previous.hasMatchedPreviously ?? false)  {
            self.body = ViewBuilder.buildEither(first: previous)
        } else {
            self.body = ViewBuilder.buildEither(second: content())
        }
    }
}

// MARK: - Extensions

extension SwitchOverCaseView {
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> {
        return .init(
            previous: self,
            predicate: predicate,
            content: content
        )
    }

    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        predicate: @escaping (Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> {
        .init(
            previous: self,
            predicate: predicate,
            content: content
        )
    }
    
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNextView<Self, Content> where Data: Equatable {
        .init(
            previous: self,
            comparate: comparate,
            content: content
        )
    }
    
    public func `default`<Content: View>(@ViewBuilder content: () -> Content) -> SwitchOverCaseDefaultView<Self, Content> {
        return .init(previous: self, content: content)
    }
}
