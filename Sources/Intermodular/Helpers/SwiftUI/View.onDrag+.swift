//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) || os(macOS) || targetEnvironment(macCatalyst)) && swift(>=5.2)

private struct _OnDragModifier<Content: View>: View {
    private let rootView: Content
    private let data: () -> NSItemProvider
    
    @usableFromInline
    init(rootView: Content, data: @escaping () -> NSItemProvider) {
        self.rootView = rootView
        self.data = data
    }
    
    @usableFromInline
    var body: some View {
        if #available(iOS 13.4, *) {
            return rootView.onDrag(data)
        } else {
            fatalError()
        }
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @_optimize(none)
    @inline(never)
    public func onDragIfAvailable(_ data: @escaping () -> NSItemProvider) -> some View {
        if #available(iOS 13.4, *) {
            return ViewBuilder.buildEither(first: _OnDragModifier(rootView: self, data: data)) as _ConditionalContent<_OnDragModifier<Self>, Self>
        } else {
            return ViewBuilder.buildEither(second: self) as _ConditionalContent<_OnDragModifier<Self>, Self>
        }
    }
}

#endif
