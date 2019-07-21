//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Binding {
    public static var unsafeDummy: Binding {
        return .init(getValue: { fatalError() }, setValue: { _ in fatalError() })
    }

    public init(_unsafeValue: Value) {
        self.init(getValue: { _unsafeValue }, setValue: { _ in fatalError() })
    }
    
    public func unsafeGetterMap<Result>(_ transform: @escaping (Value) -> Result) -> Binding<Result> {
        .init(
            getValue: { transform(self.wrappedValue) },
            setValue: { _ in fatalError() }
        )
    }

    public func set(_ newValue: Value) {
        value = newValue
    }
}
