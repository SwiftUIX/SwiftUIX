//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol _opaque_View {
    func _opaque_environmentObject<B: ObservableObject>(_: B) -> _opaque_View
    func _opaque_getViewName() -> AnyHashable?
    
    func eraseToAnyView() -> AnyView
}

// MARK: - Implementation

extension _opaque_View where Self: View {
    @inlinable
    public func _opaque_environmentObject<B: ObservableObject>(_ bindable: B) -> _opaque_View {
        PassthroughView(content: environmentObject(bindable))
    }

    @inlinable
    public func _opaque_getViewName() -> AnyHashable? {
        nil
    }
    
    @inlinable
    public func eraseToAnyView() -> AnyView {
        .init(self)
    }
}

extension ModifiedContent: _opaque_View where Content: View, Modifier: ViewModifier {

}
