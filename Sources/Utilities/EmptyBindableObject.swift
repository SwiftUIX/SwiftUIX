//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

/// An empty `BindableObject` for utility purposes.
public final class EmptyBindableObject: BindableObject {
    public let willChange = PassthroughSubject<EmptyBindableObject, Never>()

    public init() {

    }

    public func notify() {
        willChange.send(self)
    }
}
