//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Swift
import SwiftUI

public final class _CocoaListCache<Configuration: _CocoaListConfigurationType> {
    private var _cheapItemCaches: [ItemPath: CheapItemCache] = [:]
    private var _expensiveItemCaches = KeyedBoundedPriorityQueue<ItemPath, ExpensiveItemCache>(maximumCapacity: 100)
    private var _itemPathsBySection: [_AnyCocoaListSectionID: Set<ItemPath>] = [:]
    
    private var _configuration: ResolvedConfiguration?
    
    func update(
        configuration: Configuration
    ) -> Bool {
        let oldConfiguration = self._configuration
        let newConfiguration = ResolvedConfiguration(from: configuration)
        
        self._configuration = newConfiguration
        
        if let oldConfiguration {
            _configurationDidUpdate(from: oldConfiguration, to: newConfiguration)
        }
        
        return !(oldConfiguration?.id == newConfiguration.id)
    }
    
    private func _configurationDidUpdate(
        from oldConfiguration: ResolvedConfiguration,
        to newConfiguration: ResolvedConfiguration
    ) {
        let oldData = IdentifiedListSections(from: oldConfiguration.base.data)
        let newData = IdentifiedListSections(from: oldConfiguration.base.data)
        
        let identifiersDifference = oldData.identifiersDifference(from: newData)
        
        identifiersDifference.sectionsRemoved.forEach {
            self.invalidate($0)
        }
        
        identifiersDifference.itemsRemovedBySection.forEach { (section, items) in
            for item in items {
                self.invalidate(ItemPath(item: item, section: section))
            }
        }
    }
    
    func itemPath(for indexPath: IndexPath) -> ItemPath? {
        self._configuration?.indexPathToItemPathMap[indexPath]
    }
    
    subscript(
        cheap path: ItemPath
    ) -> CheapItemCache {
        get {
            if let result = _cheapItemCaches[path] {
                return result
            } else {
                let result = CheapItemCache(parent: self, id: path)
                
                _cheapItemCaches[path] = result
                _itemPathsBySection[path.section, default: []].insert(path)
                
                return result
            }
        }
    }

    subscript(
        cheap indexPath: IndexPath
    ) -> CheapItemCache? {
        guard let path = itemPath(for: indexPath) else {
            return nil
        }
        
        return self[cheap: path]
    }

    subscript(
        expensive path: ItemPath
    ) -> ExpensiveItemCache {
        get {
            if let result = _expensiveItemCaches[path] {
                return result
            } else {
                let result = ExpensiveItemCache(parent: self, id: path)
                
                _expensiveItemCaches[path] = result
                _itemPathsBySection[path.section, default: []].insert(path)
                
                return result
            }
        }
    }
    
    subscript(
        expensive indexPath: IndexPath
    ) -> ExpensiveItemCache? {
        guard let path = itemPath(for: indexPath) else {
            return nil
        }
        
        return self[expensive: path]
    }
    
    func invalidate(_ path: ItemPath) {
        self._cheapItemCaches[path] = nil
        self._itemPathsBySection[path.section, default: []].remove(path)
    }
    
    func invalidate(_ section: _AnyCocoaListSectionID) {
        let itemPaths = self._itemPathsBySection[section] ?? []
        
        self._itemPathsBySection[section] =  nil
    
        for path in itemPaths {
            self._cheapItemCaches.removeValue(forKey: path)
        }
    }

    func invalidate() {
        self._configuration = nil
        self._cheapItemCaches = [:]
        self._itemPathsBySection = [:]
    }
    
    struct ResolvedConfiguration {
        let base: Configuration
        
        private(set) var id: _DefaultCocoaListDataSourceID
        private(set) var sectionIDToSectionIndexMap: [AnyHashable: Int] = [:]
        private(set) var sectionIndexToSectionIDMap: [Int: AnyHashable] = [:]
        private(set) var sectionIDToItemIDsMap: [AnyHashable: Set<AnyHashable>] = [:]
        private(set) var indexPathToItemPathMap: [IndexPath: ItemPath] = [:]
        private(set) var itemPathToIndexPathMap: [ItemPath: IndexPath] = [:]

        init(from base: Configuration) {
            self.base = base
            self.id = .init(from: base.data)
            
            for (sectionIndex, section) in base.data.payload.enumerated() {
                let sectionID = section.model[keyPath: base.data.sectionID]
                
                self.sectionIDToSectionIndexMap[sectionID] = sectionIndex
                self.sectionIndexToSectionIDMap[sectionIndex] = sectionID
                
                for (itemIndex, element) in section.items.enumerated() {
                    let itemID = element[keyPath: base.data.itemID]
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    let itemPath = ItemPath(item: itemID, section: sectionID)

                    _ = self.sectionIDToItemIDsMap[sectionID, default: []].insert(itemID)
                    
                    self.indexPathToItemPathMap[indexPath] = itemPath
                    self.itemPathToIndexPathMap[itemPath] = indexPath
                }
            }
        }
    }
}

extension _CocoaListCache {
    public final class CheapItemCache {
        private unowned let parent: _CocoaListCache
        
        private let id: ItemPath
        
        var lastContentSize: CGSize?
        
        public init(
            parent: _CocoaListCache,
            id: ItemPath
        ) {
            self.parent = parent
            self.id = id
        }
    }
    
    public final class ExpensiveItemCache {
        private unowned let parent: _CocoaListCache
        
        private let id: ItemPath
        
        #if os(macOS)
        var cellContentView: AppKitOrUIKitView?
        #endif
        
        public init(
            parent: _CocoaListCache,
            id: ItemPath
        ) {
            self.parent = parent
            self.id = id
        }
    }
    
    @frozen
    public struct ItemPath: Hashable {
        public let item: _AnyCocoaListItemID
        public let section: _AnyCocoaListSectionID
        
        public init(
            item: _AnyCocoaListItemID,
            section: _AnyCocoaListSectionID
        ) {
            self.item = item
            self.section = section
        }
    }
}

#endif
