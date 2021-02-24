//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CollectionViewProxy {
    weak var hostingCollectionViewController: _opaque_UIHostingCollectionViewController?
    
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        hostingCollectionViewController?.scrollTo(id, anchor: anchor)
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        hostingCollectionViewController?.select(id, anchor: anchor)
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        hostingCollectionViewController?.deselect(id)
    }
}

public struct CollectionViewReader<Content: View>: View {
    public let content: (CollectionViewProxy) -> Content
    
    @State var collectionViewProxy = CollectionViewProxy()
    
    public init(
        @ViewBuilder content: @escaping (CollectionViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(collectionViewProxy)
            .environment(\._collectionViewProxy, $collectionViewProxy)
    }
}

#endif
