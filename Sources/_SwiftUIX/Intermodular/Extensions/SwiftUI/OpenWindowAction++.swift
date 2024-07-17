//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OpenWindowAction {
    public func callAsFunction<ID: RawRepresentable<String>>(
        id: ID
    ) {        
        self.callAsFunction(id: id.rawValue)
    }
}

#endif
