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
    
    @ViewBuilder
    public func modify<T: View, U: Equatable>(
        if keyPath: KeyPath<EnvironmentValues, U>,
        equals comparate: U,
        transform: @escaping (Self) -> T
    ) -> some View {
        EnvironmentValueAccessView(keyPath) { value in
            if value == comparate {
                transform(self)
            } else {
                self
            }
        }
    }
}
