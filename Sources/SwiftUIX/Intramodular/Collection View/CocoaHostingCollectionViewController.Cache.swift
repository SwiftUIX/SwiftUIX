//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension CocoaHostingCollectionViewController.Cache {
    typealias _ParentControllerType = CocoaHostingCollectionViewController

    typealias CellOrSupplementaryViewContentConfiguration = _ParentControllerType.SupplementaryViewType.ContentConfiguration
    typealias CellOrSupplementaryViewContentPreferences = _ParentControllerType.SupplementaryViewType.ContentPreferences
    typealias CellOrSupplementaryViewContentCache = _ParentControllerType.SupplementaryViewType.ContentCache
    typealias CellType = _ParentControllerType.CellType
    typealias SupplementaryViewType = _ParentControllerType.SupplementaryViewType
}

extension CocoaHostingCollectionViewController {
    class Cache: NSObject {
        unowned private let parent: CocoaHostingCollectionViewController
        
        var contentHostingControllerCache =  KeyedBoundedPriorityQueue<CellType.ContentConfiguration.ID, CocoaCollectionElementHostingController<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>>()
                
        private var contentIdentifierToCacheMap: [CellType.ContentConfiguration.ID: CellType.ContentCache] = [:]
        private var contentIdentifierToPreferencesMap: [CellType.ContentConfiguration.ID: CellType.ContentPreferences] = [:]
        private var contentIdentifierToIndexPathMap: [CellType.ContentConfiguration.ID: IndexPath] = [:]
        private var indexPathToContentIdentifierMap: [IndexPath: CellType.ContentConfiguration.ID] = [:]
        private var itemIdentifierHashToIndexPathMap: [Int: IndexPath] = [:]
                
        var prototypeContentHostingController: CocoaCollectionElementHostingController<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>?

        init(parent: CocoaHostingCollectionViewController) {
            self.parent = parent
        }
    }
}

extension CocoaHostingCollectionViewController.Cache {
    func preconfigure(cell: CellType) {
        cell.contentCache = .init()
        cell.contentPreferences = .init()
        
        guard let id = cell.cellContentConfiguration?.id else {
            return
        }
        
        if let cellCache = contentIdentifierToCacheMap[id] {
            cell.contentCache = cellCache
        }
        
        if let cellPreferences = contentIdentifierToPreferencesMap[id] {
            cell.contentPreferences = cellPreferences
        }
    }
    
    func preconfigure(supplementaryView: SupplementaryViewType) {
        supplementaryView.cache = .init()
        
        guard let id = supplementaryView.configuration?.id else {
            return
        }
        
        if let supplementaryViewCache = contentIdentifierToCacheMap[id] {
            supplementaryView.cache = supplementaryViewCache
        }
    }
    
    func sizeForCellOrSupplementaryView(
        withReuseIdentifier reuseIdentifier: String,
        at indexPath: IndexPath
    ) -> CGSize {
        guard let dataSource = parent.dataSource, dataSource.contains(indexPath) else {
            return .init(width: 1.0, height: 1.0)
        }
        
        guard let configuration = parent.contentConfiguration(for: indexPath, reuseIdentifier: reuseIdentifier) else {
            assertionFailure()
            
            return .init(width: 1, height: 1)
        }
        
        if let size = contentIdentifierToCacheMap[configuration.id]?.contentSize {
            return size
        } else {
            let contentHostingController: CocoaCollectionElementHostingController<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
            
            let contentHostingControllerConfiguration = _CollectionViewElementContent.Configuration(
                _reuseCellRender: parent.configuration.unsafeFlags.contains(.reuseCellRender),
                _collectionViewProxy: .init(parent),
                _cellProxyBase: nil,
                contentConfiguration: configuration,
                contentState: nil,
                contentPreferences: nil,
                contentCache: .init(),
                content: configuration.makeContent()
            )
            
            if parent.configuration.unsafeFlags.contains(.cacheCellContentHostingControllers) {
                if let cachedContentHostingController = contentHostingControllerCache[configuration.id] {
                    contentHostingController = cachedContentHostingController
                    
                    contentHostingController.rootView.configuration = contentHostingControllerConfiguration
                } else {
                    contentHostingController = .init(configuration: contentHostingControllerConfiguration)
                }
                
                if contentHostingControllerCache[configuration.id] == nil {
                    contentHostingControllerCache[configuration.id] = contentHostingController
                }
            } else {
                if let prototypeContentHostingController = prototypeContentHostingController {
                    contentHostingController = prototypeContentHostingController
                    
                    contentHostingController.rootView.configuration = contentHostingControllerConfiguration
                } else {
                    contentHostingController = .init(configuration: contentHostingControllerConfiguration)
                    
                    prototypeContentHostingController = contentHostingController
                }
            }
                        
            if contentHostingController.rootView.configuration.contentConfiguration.maximumSize != parent.maximumCollectionViewCellSize {
                contentHostingController.rootView.configuration.contentConfiguration.maximumSize = parent.maximumCollectionViewCellSize
            }
            
            let size = contentHostingController
                .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                .clamped(to: parent.maximumCollectionViewCellSize.rounded(.down))
                                    
            guard !(size.width == 1 && size.height == 1) && !size.isAreaZero else {
                return size
            }
            
            contentIdentifierToCacheMap[configuration.id, default: .init()].contentSize = size
            contentIdentifierToIndexPathMap[configuration.id] = indexPath
            indexPathToContentIdentifierMap[configuration.indexPath] = configuration.id
            
            if let itemIdentifier = configuration.itemIdentifier {
                itemIdentifierHashToIndexPathMap[itemIdentifier.hashValue] = indexPath
            }
            
            return size
        }
    }
}

extension CocoaHostingCollectionViewController.Cache {
    public func setContentCache(
        _ cache: CellOrSupplementaryViewContentCache?,
        for id: CellOrSupplementaryViewContentConfiguration.ID
    ) {
        contentIdentifierToCacheMap[id] = cache
    }

    func invalidate() {
        contentIdentifierToCacheMap = [:]
        contentIdentifierToPreferencesMap = [:]
        contentIdentifierToIndexPathMap = [:]
        indexPathToContentIdentifierMap = [:]
        itemIdentifierHashToIndexPathMap = [:]
    }
    
    func invalidateContent(
        at indexPath: IndexPath,
        withID suppliedID: CellType.ContentConfiguration.ID? = nil
    ) {
        guard let id = suppliedID ?? indexPathToContentIdentifierMap[indexPath] else {
            return
        }
        
        contentIdentifierToCacheMap[id] = nil
        contentIdentifierToIndexPathMap[id] = nil
        indexPathToContentIdentifierMap[indexPath] = nil
        itemIdentifierHashToIndexPathMap[id.item.hashValue] = nil
    }
}

extension CocoaHostingCollectionViewController.Cache {
    func preferences(
        forID id: CocoaHostingCollectionViewController.CellType.ContentConfiguration.ID
    ) -> Binding<CocoaHostingCollectionViewController.CellType.ContentPreferences?> {
        .init(
            get: { [weak self] in
                guard let `self` = self else {
                    return nil
                }
                
                return self.contentIdentifierToPreferencesMap[id]
            },
            set: { [weak self] newValue in
                guard let `self` = self else {
                    return
                }
                
                let oldValue = self.contentIdentifierToPreferencesMap[id]
                
                if oldValue != newValue {
                    self.contentIdentifierToPreferencesMap[id] = newValue
                }
            }
        )
    }
    
    func preferences(
        forContentAt indexPath: IndexPath
    ) -> Binding<CocoaHostingCollectionViewController.CellType.ContentPreferences?> {
        .init(
            get: { [weak self] in
                guard let `self` = self else {
                    return nil
                }
                
                if let id = self.indexPathToContentIdentifierMap[indexPath] {
                    return self.preferences(forID: id).wrappedValue
                } else {
                    return nil
                }
            },
            set: { [weak self] newValue in
                guard let `self` = self else {
                    return
                }
                
                if let id = self.indexPathToContentIdentifierMap[indexPath] {
                    self.preferences(forID: id).wrappedValue = newValue
                }
            }
        )
    }

    func firstIndexPath(for identifier: AnyHashable) -> IndexPath? {
        if let indexPath = itemIdentifierHashToIndexPathMap[identifier.hashValue] {
            return indexPath
        } else {
            return nil
        }
    }
    
    func identifier(for indexPath: IndexPath) -> CocoaHostingCollectionViewController.CellType.ContentConfiguration.ID? {
        indexPathToContentIdentifierMap[indexPath]
    }
}

#endif
