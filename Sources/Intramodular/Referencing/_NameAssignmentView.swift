//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view modifier that attaches a view name.
fileprivate struct _NameAssignmentView<Content: View>: View {
    private let content: Content
    private let name: AnyHashable
    private let _namespace: Any?
    private let id: AnyHashable?
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    var namespace: Namespace.ID? {
        _namespace as? Namespace.ID
    }
    
    init(content: Content, name: AnyHashable, namespace: Any?, id: AnyHashable?) {
        self.content = content
        self.name = name
        self._namespace = namespace
        self.id = id
    }
    
    var body: some View {
        content.background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: _NamedViewDescription.PreferenceKey.self,
                    value:  .init(
                        _NamedViewDescription(
                            name: name,
                            id: id,
                            geometry: geometry
                        )
                    )
                )
            }
        }
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name<ID: Hashable>(_ name: AnyHashable, id: ID) -> some View {
        _NameAssignmentView(
            content: self,
            name: name,
            namespace: nil,
            id: id
        )
    }
        
    /// Set a name for `self`.
    public func name(_ name: AnyHashable) -> some View {
        _NameAssignmentView(
            content: self,
            name: name,
            namespace: nil,
            id: nil
        )
    }
    
    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> some View {
        self.name(AnyHashable(name))
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

// MARK: - Auxiliary Implementation -

public struct _NamedViewDescriptionPreferenceKey: SwiftUI.PreferenceKey {
    public struct Value: Hashable, Sequence {
        public typealias Element = _NamedViewDescription
        
        var base: [AnyHashable: Element]
        
        init(_ element: Element) {
            self.base = [element.name: element]
        }
        
        init() {
            self.base = Dictionary()
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(base)
        }
        
        public func makeIterator() -> AnyIterator<Element> {
            .init(base.values.makeIterator())
        }
        
        subscript(_ key: AnyHashable) -> _NamedViewDescription? {
            base[key]
        }
    }
    
    public static var defaultValue: Value {
        Value()
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        var _value = value
        let nextValue = nextValue()
        
        guard !nextValue.base.isEmpty else {
            return
        }
        
        _value.base.merge(nextValue.base, uniquingKeysWith: { lhs, rhs in lhs })
        
        value = _value
    }
}

extension _NamedViewDescription {
    public typealias PreferenceKey = _NamedViewDescriptionPreferenceKey
}
