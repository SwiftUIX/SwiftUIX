//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct _OnDragModifier<Content: View>: View {
    let rootView: Content
    let data: () -> NSItemProvider
    
    var body: some View {
        if #available(iOS 13.4, *) {
            return rootView.onDrag(data)
        } else {
            fatalError()
        }
    }
}

extension View {
    public func onDragIfAvailable(_ data: @escaping () -> NSItemProvider) -> some View {
        if #available(iOS 13.4, *) {
            return ViewBuilder.buildEither(first: _OnDragModifier(rootView: self, data: data)) as _ConditionalContent<_OnDragModifier<Self>, Self>
        } else {
            return ViewBuilder.buildEither(second: self) as _ConditionalContent<_OnDragModifier<Self>, Self>
        }
    }
}
