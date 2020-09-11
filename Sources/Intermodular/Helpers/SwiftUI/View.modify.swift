//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    @ViewBuilder
    public func modify<T: View>(
        if predicate: Bool,
        transform: (Self) -> T
    ) -> some View {
        if predicate {
            transform(self)
        } else {
            self
        }
    }
}
