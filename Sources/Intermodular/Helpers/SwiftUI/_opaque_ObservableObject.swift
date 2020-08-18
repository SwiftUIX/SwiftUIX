//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _opaque_ObservableObject {
    func asEnvironmentObject<V: View>(in _: V) -> AnyView
}

// MARK: - Implementation -

extension ObservableObject where Self: _opaque_ObservableObject {
    public func asEnvironmentObject<V: View>(in view: V) -> AnyView {
        view.environmentObject(self).eraseToAnyView()
    }
}
