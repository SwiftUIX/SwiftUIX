//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Binding {
    public func _mapGetter<Result>(_ transform: @escaping (Value) -> Result) -> Binding<Result> {
        .init(
            get: { transform(self.wrappedValue) },
            set: { _ in fatalError() }
        )
    }
}
