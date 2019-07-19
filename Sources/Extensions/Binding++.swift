//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Binding {
    public func unsafeGetterMap<Result>(_ transform: @escaping (Value) -> Result) -> Binding<Result> {
        .init(
            getValue: { transform(self.wrappedValue) },
            setValue: { _ in fatalError() }
        )
    }
}
