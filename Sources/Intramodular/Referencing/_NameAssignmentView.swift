//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view modifier that attaches a view name.
fileprivate struct _NameAssignmentView<Content: View>: View {
    private let content: Content
    private let name: ViewName
    private let _namespace: Any?
    private let id: AnyHashable?
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    var namespace: Namespace.ID? {
        _namespace as? Namespace.ID
    }
    
    init(content: Content, name: ViewName, namespace: Any?, id: AnyHashable?) {
        self.content = content
        self.name = name
        self._namespace = namespace
        self.id = id
    }
    
    var body: some View {
        content
            .environment(\._name, name)
            .background(
                GeometryReader { geometry in
                    ZeroSizeView().anchorPreference(
                        key: _NamedViewDescription.PreferenceKey.self,
                        value: .bounds
                    ) {
                        .init(
                            _NamedViewDescription(
                                name: name,
                                id: id,
                                bounds: $0,
                                globalBounds: geometry.frame(in: .global)
                            )
                        )
                    }
                }
            )
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name<ID: Hashable>(_ name: ViewName, id: ID) -> some View {
        _NameAssignmentView(
            content: self,
            name: name.withViewType(type(of: self)),
            namespace: nil,
            id: id
        )
    }
        
    /// Set a name for `self`.
    public func name(_ name: ViewName) -> some View {
        _NameAssignmentView(
            content: self,
            name: name.withViewType(type(of: self)),
            namespace: nil,
            id: nil
        )
    }
    
    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> some View {
        self.name(ViewName(name))
    }
    
    /// Set a name for `self`.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public func name<H: Hashable>(_ name: H, in namespace: Namespace.ID) -> some View {
        _NameAssignmentView(
            content: self,
            name: .init(name),
            namespace: namespace,
            id: nil
        )
    }
}
