//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Swift
import SwiftUI

extension _VariadicViewChildren {
    struct _CocoaListContentAdapter: _CocoaListConfigurationType {
        let identifiers: [_CocoaListItemID]
        let indexToIDMap: [Int: _CocoaListItemID]
        let idToSubviewMap: [_CocoaListItemID: _VariadicViewChildren.Element]
        
        public var preferences: _CocoaListPreferences = nil

        var data: DataSource {
            .init(parent: self)
        }
        
        var viewProvider: ViewProvider {
            .init(parent: self)
        }
        
        init(
            _ data: _VariadicViewChildren,
            preferences: _CocoaListPreferences
        ) {
            var identifiers: [_CocoaListItemID] = Array()
            var indexToIDMap: [Int: _CocoaListItemID] = [:]
            var idToSubviewMap: [_CocoaListItemID: _VariadicViewChildren.Element] = [:]
            
            for (index, subview) in data.enumerated() {
                let id = subview[_CocoaListItemID.self] ?? _CocoaListItemID(id: subview.id)
                
                identifiers.append(id)
                
                indexToIDMap[index] = id
                idToSubviewMap[id] = subview
            }
            
            self.identifiers = identifiers
            self.indexToIDMap = indexToIDMap
            self.idToSubviewMap = idToSubviewMap
            self.preferences = preferences
        }
    }
}

extension _VariadicViewChildren._CocoaListContentAdapter {
    struct DataSource: _CocoaListDataSourceType {
        public typealias ID = _DefaultCocoaListDataSourceID
        
        public typealias SectionType = Int
        public typealias ItemType = _CocoaListItemID
        
        let parent: _VariadicViewChildren._CocoaListContentAdapter
        
        var payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>> {
            AnyRandomAccessCollection([
                ListSection(0, items: {
                    parent.identifiers
                })
            ])
        }
        
        var sectionID: KeyPath<Int, _AnyCocoaListSectionID> {
            \.self._SwiftUIX_erasedAsCocoaListSectionID
        }
        
        var itemID: KeyPath<ItemType, _AnyCocoaListItemID> {
            \.self._SwiftUIX_erasedAsCocoaListItemID
        }
        
        init(parent: _VariadicViewChildren._CocoaListContentAdapter) {
            self.parent = parent
        }
    }
    
    struct ViewProvider: _CocoaListViewProviderType {
        public typealias SectionType = Int
        public typealias SectionHeader = Never
        public typealias SectionFooter = Never
        public typealias ItemType = _CocoaListItemID
        public typealias RowContent = AnyView
        
        let parent: _VariadicViewChildren._CocoaListContentAdapter
        
        public var sectionHeader: (SectionType) -> SectionHeader {
            return { _ in
                Never._SwiftUIX_produce()
            }
        }
        
        public var sectionFooter: (SectionType) -> SectionFooter {
            return { _ in
                Never._SwiftUIX_produce()
            }
        }
        
        public var rowContent: (ItemType) -> RowContent {
            return { item in
                parent.idToSubviewMap[item]!.eraseToAnyView()
            }
        }
    }
}

#endif
