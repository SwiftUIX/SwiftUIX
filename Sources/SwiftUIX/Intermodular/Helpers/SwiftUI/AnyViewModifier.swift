//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type-erased view modifier.
@_documentation(visibility: internal)
public struct AnyViewModifier: ViewModifier {
    private let makeBody: (Content) -> AnyView

    public init<T: ViewModifier>(_ modifier: T) {
        self.makeBody = { $0.modifier(modifier).eraseToAnyView() }
    }

    public init<Body: View>(
        @ViewBuilder _ makeBody: @escaping (Content) -> Body
    ) {
        self.makeBody = { makeBody($0).eraseToAnyView() }
    }
    
    public init() {
        self.init({ $0.eraseToAnyView() })
    }

    public func body(content: Content) -> some View {
        makeBody(content)
    }
    
    public func concatenate<T: ViewModifier>(
        _ modifier: T
    ) -> AnyViewModifier {
        AnyViewModifier(concat(modifier))
    }
}

// MARK: - Supplementary

extension View {
    @ViewBuilder
    func modifiers(
        _ modifiers: [AnyViewModifier]
    ) -> some View {
        if modifiers.isEmpty {
            self
        } else {
            modifiers.reduce(into: eraseToAnyView()) { (view, modifier) -> () in
                view = view.modifier(modifier).eraseToAnyView()
            }
        }
    }
}

extension ViewModifier {
    public func eraseToAnyViewModifier() -> AnyViewModifier {
        .init(self)
    }
}
