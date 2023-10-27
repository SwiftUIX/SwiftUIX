//
// Copyright (c) Vatsal Maot
//

import SwiftUI

public struct _ViewTraitsReader<Key: _ViewTraitKey, Content: View>: View where Key.Value: Equatable {
    private let key: Key.Type
    private let content: ([AnyHashable: Key.Value]) -> Content
    
    @State private var value = [AnyHashable: Key.Value]()
    
    
    public init(
        _ key: Key.Type = Key.self,
        @ViewBuilder content: @escaping ([AnyHashable: Key.Value]) -> Content
    ) {
        self.key = key
        self.content = content
    }
    
    public var body: some View {
        content(value)._onViewTraitsChange(key) {
            self.value = $0
        }
    }
}

extension View {
    public func _onViewTraitsChange<K: _ViewTraitKey>(
        _ key: K.Type,
        perform action: @escaping ([AnyHashable: K.Value]) -> Void
    ) -> some View where K.Value: Equatable {
        modifier(_OnChangeOfViewTraits(key: key, action: action))
    }
}

struct _OnChangeOfViewTraits<Key: _ViewTraitKey>: ViewModifier where Key.Value: Equatable {
    let key: Key.Type
    let action: ([AnyHashable: Key.Value]) -> Void

    @ViewStorage private var payload: [AnyHashable: Key.Value] = [:]
    
    func body(content: Content) -> some View {
        _VariadicViewAdapter(content) { content in
            let traits = Dictionary(
                content.children.map({ (AnyHashable($0.id), $0[Key.self]) }),
                uniquingKeysWith: { lhs, rhs in lhs }
            )
            
            _ForEachSubview(enumerating: content) { index, subview in
                subview.background {
                    Group {
                        // Only attach to the first view, we don't want to add a change observer n times.
                        if index == 0 {
                            subview.onChange(of: traits) { _ in
                                setPayload(traits)
                            }
                        }
                    }
                }
            }
            
            // Clear the payload if there are no views.
            if content.children.isEmpty && !payload.isEmpty {
                PerformAction {
                    self.payload = [:]
                }
            }
        }
    }
    
    private func setPayload(_ payload: [AnyHashable: Key.Value]) {
        self.payload = payload
        
        action(payload)
    }
}
