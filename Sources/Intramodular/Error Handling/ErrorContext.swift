//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public final class ErrorContext: ObservableObject {
    fileprivate var errors: [Error] {
        didSet {
            if !(oldValue ~= errors) {
                objectWillChange.send()
            }
        }
    }
    
    public init(_ errors: [Error]) {
        self.errors = errors
    }
    
    public convenience init() {
        self.init([])
    }
}

extension ErrorContext {
    public func push(_ error: Error) {
        errors.append(error)
    }
    
    public func merge(_ other: ErrorContext) {
        errors += other.errors
    }
    
    public func reset() {
        errors = []
    }
    
    public func withCriticalScope(perform action: () throws -> Void) {
        do {
            try action()
        } catch {
            DispatchQueue.asyncOnMainIfNecessary {
                self.push(error)
            }
        }
    }
}

// MARK: - Protocol Implementation -

extension ErrorContext: Collection {
    public var startIndex: Int {
        errors.startIndex
    }
    
    public var endIndex: Int {
        errors.endIndex
    }
    
    public func index(after i: Int) -> Int {
        errors.index(after: i)
    }
    
    public subscript(_ position: Int) -> Error {
        errors[position]
    }
}

extension ErrorContext: Equatable {
    public static func == (lhs: ErrorContext, rhs: ErrorContext) -> Bool {
        lhs.errors ~= rhs.errors
    }
}

extension ErrorContext: Sequence {
    public func makeIterator() -> Array<Error>.Iterator {
        errors.makeIterator()
    }
}

// MARK: - API -

extension View {
    public func errorContext(_ context: ErrorContext) -> some View {
        environment(\.errorContext, context)
            .environmentObject(context)
    }
    
    public func pushError(_ error: Error?) -> some View {
        background(error.ifSome { error in
            ZeroSizeView().preference(
                key: ErrorContextPreferenceKey.self,
                value: ErrorContext([error])
            )
        })
    }
    
    /// Adds an action to perform when this view appears.
    public func onAppear(perform action: (() throws -> Void)?) -> some View {
        EnvironmentValueAccessView(\.errorContext) { errorContext in
            self.onAppear(perform: action.map({ action in {
                do {
                    try action()
                } catch {
                    errorContext.push(error)
                }
            } }))
        }
    }
    
    /// Adds an action to perform when this view disappears.
    public func onDisappear(perform action: (() throws -> Void)?) -> some View {
        EnvironmentValueAccessView(\.errorContext) { errorContext in
            self.onDisappear(perform: action.map({ action in {
                do {
                    try action()
                } catch {
                    errorContext.push(error)
                }
            } }))
        }
    }
}

// MARK: - Helpers -

private final class ErrorContextEnvironmentKey: EnvironmentKey {
    static let defaultValue: ErrorContext = .init([])
}

extension EnvironmentValues {
    public var errorContext: ErrorContext {
        get {
            self[ErrorContextEnvironmentKey.self]
        } set {
            self[ErrorContextEnvironmentKey.self] = newValue
        }
    }
}

final class ErrorContextPreferenceKey: PreferenceKey {
    typealias Value = ErrorContext
    
    static let defaultValue = ErrorContext()
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue())
    }
}

private func ~= (lhs: [Error], rhs: [Error]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    
    for index in 0..<lhs.count {
        if String(describing: lhs[index]) != String(describing: rhs[index]) {
            return false
        }
    }
    
    return true
}
