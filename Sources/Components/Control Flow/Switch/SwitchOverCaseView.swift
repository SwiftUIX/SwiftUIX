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

    /// The data being compared with in the control flow.
    var comparate: Data { get }

    /// The predicate being used for data comparison in the control flow.
    var predicate: (Data, Data) -> Bool { get }

    /// Whether `self` represents a match in the control flow.
    var isAMatch: Bool { get }
}

/// A view representing first `case` statement in a `switch` control flow.
public struct SwitchOverCaseFirst<Data, Content: View>: SwitchOverCaseView {
    public let comparator: Data
    public let comparate: Data
    public let predicate: (Data, Data) -> Bool

    public let body: Content?

    public var isAMatch: Bool {
        return predicate(comparator, comparate)
    }

    public init(
        comparator: Data,
        comparate: Data,
        predicate: @escaping (Data, Data) -> Bool,
        content: () -> Content
    ) {
        self.comparator = comparator
        self.comparate = comparate
        self.predicate = predicate

        body = predicate(comparator, comparate) ? content() : nil
    }
}

extension SwitchOverCaseFirst where Data: Equatable {
    public init(
        comparator: Data,
        comparate: Data,
        content: () -> Content
    )  {
        self.comparator = comparator
        self.comparate = comparate
        self.predicate = { $0 == $1 }

        body = predicate(comparator, comparate) ? content() : nil
    }
}

/// A view representing a noninitial `case` statement in a `switch` control flow.
public struct SwitchOverCaseNext<PreviousCase: SwitchOverCaseView, Content: View>: SwitchOverCaseView {
    public typealias Data = PreviousCase.Data

    public let previous: PreviousCase

    public var comparator: Data {
        return previous.comparator
    }

    public let comparate: Data
    public let predicate: (Data, Data) -> Bool

    public let body: _ConditionalContent<PreviousCase, Content?>

    public var isAMatch: Bool {
        guard !previous.isAMatch else {
            return false
        }

        return predicate(comparator, comparate)
    }

    public init(
        previous: PreviousCase,
        comparate: Data,
        predicate: @escaping (Data, Data) -> Bool,
        content: () -> Content
    ) {
        self.previous = previous
        self.comparate = comparate
        self.predicate = predicate

        if previous.isAMatch  {
            self.body = ViewBuilder.buildEither(first: previous)
        } else {
            if predicate(previous.comparator, comparate) {
                self.body = ViewBuilder.buildEither(second: content())
            } else {
                self.body = ViewBuilder.buildEither(second: nil)
            }
        }
    }
}

extension SwitchOverCaseNext where Data: Equatable {
    public init(
        previous: PreviousCase,
        comparate: Data,
        content: () -> Content
    )  {
        self.init(
            previous: previous,
            comparate: comparate,
            predicate: { $0 == $1 },
            content: content
        )
    }
}

/// A view representing a `default` statement in a `switch` control flow.
public struct SwitchOverCaseDefault<PreviousCase: SwitchOverCaseView, Content: View> {
    public typealias Data = PreviousCase.Data

    public let previous: PreviousCase
    public let body: _ConditionalContent<PreviousCase, Content>

    public init(previous: PreviousCase, content: () -> Content) {
        self.previous = previous

        if previous.isAMatch  {
            self.body = ViewBuilder.buildEither(first: previous)
        } else {
            self.body = ViewBuilder.buildEither(second: content())
        }
    }
}

// MARK: - Extensions -

extension SwitchOverCaseView {
    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        predicate: @escaping (Data, Data) -> Bool,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNext<Self, Content> {
        .init(
            previous: self,
            comparate: comparate,
            predicate: predicate,
            content: content
        )
    }

    /// Handles a case in a `switch` control flow.
    public func `case`<Content: View>(
        _ comparate: Data,
        @ViewBuilder content: () -> Content
    ) -> SwitchOverCaseNext<Self, Content> where Data: Equatable {
        .init(
            previous: self,
            comparate: comparate,
            content: content
        )
    }

    public func `default`<Content: View>(@ViewBuilder content: () -> Content) -> SwitchOverCaseDefault<Self, Content> {
        return .init(previous: self, content: content)
    }
}
