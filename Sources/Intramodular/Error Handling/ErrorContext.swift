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
    public func add(_ error: Error) {
        errors.append(error)
    }
    
    public func merge(_ other: ErrorContext) {
        errors += other.errors
    }
    
    public func reset() {
        errors = []
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
    
    public func attachError(_ error: Error?) -> some View {
        error.ifSome { error in
            preference(key: ErrorContextPreferenceKey.self, value: ErrorContext([error]))
        }.else {
            self
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
            self[ErrorContextEnvironmentKey]
        } set {
            self[ErrorContextEnvironmentKey] = newValue
        }
    }
}

final class ErrorContextPreferenceKey: PreferenceKey {
    typealias Value = ErrorContext
    
    static var defaultValue: Value {
        return .init()
    }
    
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
