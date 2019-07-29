//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Binding {
    public static var unsafeDummy: Binding {
        return .init(get: { fatalError() }, set: { _ in fatalError() })
    }

    public init(_unsafeValue: Value) {
        self.init(get: { _unsafeValue }, set: { _ in fatalError() })
    }

    public func unsafeGetterMap<Result>(_ transform: @escaping (Value) -> Result) -> Binding<Result> {
        .init(
            get: { transform(self.wrappedValue) },
            set: { _ in fatalError() }
        )
    }

    public func set(_ newValue: Value) {
        value = newValue
    }
}
