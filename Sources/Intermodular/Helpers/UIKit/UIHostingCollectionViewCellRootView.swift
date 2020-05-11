//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct UIHostingCollectionViewCellRootView<Item: Identifiable, Content: View>: View {
    struct _ListRowManager: ListRowManager {
        weak var base: UIHostingCollectionViewCell<Item, Content>?
        
        var isHighlighted: Bool = false
        
        func _animate(_ action: () -> ()) {
            base?.collectionViewController.collectionViewLayout.invalidateLayout()
        }
        
        func _reload() {
            base?.reload()
        }
    }
    
    var manager: _ListRowManager
    
    init(base: UIHostingCollectionViewCell<Item, Content>?) {
        self.manager = .init(base: base)
    }
    
    public var body: some View {
        manager.base.ifSome { base in
            base
                .makeContent(base.item)
                .environment(\.listRowManager, manager)
                .onPreferenceChange(_ListRowPreferencesKey.self, perform: { base.listRowPreferences = $0 })
                .id(base.item.id)
        }
    }
}

#endif
