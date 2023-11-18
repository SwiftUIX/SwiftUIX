//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view whose child is defined as a function of a preference value read from within the child.
public struct _PreferenceTraitsReader<Content: View>: View {
    private let content: (_PreferenceTraitsStorage) -> Content
    
    @State private var value = _PreferenceTraitsStorage()
    
    public init(
        @ViewBuilder content: @escaping (_PreferenceTraitsStorage) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        _VariadicViewAdapter(content(value)) { content in
            if content.children.count == 1 {
                _ForEachSubview(content) { subview in
                    let traits = subview.traits._preferenceTraitsStorage
                    
                    subview.background {
                        PerformAction {
                            if self.value != traits {
                                self.value = traits
                            }
                        }
                    }
                }
            } else {
                /*PerformAction {
                 assertionFailure()
                 }*/
            }
        }
    }
}
