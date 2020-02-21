//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension View {
    public func navigated() -> some View {
        CustomNavigationView {
            self
        }
    }
}

#endif
