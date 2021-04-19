//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension UIHostingCollectionViewController {
    class Cache: NSObject, UICollectionViewDelegateFlowLayout {
        typealias UICollectionViewCellType = UIHostingCollectionViewController.UICollectionViewCellType
        
        unowned let parent: UIHostingCollectionViewController
        
        private var cellIdentifierToContentSizeMap: [UICollectionViewCellType.Configuration.ID: CGSize] = [:]
        private var cellIdentifierToPreferencesMap: [UICollectionViewCellType.Configuration.ID: UICollectionViewCellType.Preferences] = [:]
        private var cellIdentifierToCacheMap: [UICollectionViewCellType.Configuration.ID: UICollectionViewCellType.Cache] = [:]
        private var cellIdentifierToIndexPathMap: [UICollectionViewCellType.Configuration.ID: IndexPath] = [:]
        private var indexPathToContentSizeMap: [IndexPath: CGSize] = [:]
        private var indexPathToCellIdentifierMap: [IndexPath: UICollectionViewCellType.Configuration.ID] = [:]
        
        private var supplementaryViewIdentifierToContentSizeMap: [UICollectionViewSupplementaryViewType.Configuration.ID: CGSize] = [:]
        private var supplementaryViewIdentifierToIndexPathMap: [UICollectionViewSupplementaryViewType.Configuration.ID: IndexPath] = [:]
        private var indexPathToSupplementaryViewContentSizeMap: [String: [IndexPath: CGSize]] = [:]
        
        private var itemIdentifierHashToIndexPathMap: [Int: IndexPath] = [:]
        
        private let prototypeHeaderView = UICollectionViewSupplementaryViewType()
        private let prototypeCell = UICollectionViewCellType()
        private let prototypeFooterView = UICollectionViewSupplementaryViewType()
        
        init(parent: UIHostingCollectionViewController) {
            self.parent = parent
        }
        
        func preconfigure(cell: UICollectionViewCellType) {
            cell.cache = .init()
            cell.preferences = .init()
            
            guard let id = cell.configuration?.id else {
                return
            }
            
            if let cellCache = cellIdentifierToCacheMap[id] {
                cell.cache = cellCache
            }
            
            if let cellPreferences = cellIdentifierToPreferencesMap[id] {
                cell.preferences = cellPreferences
            }
        }
        
        func invalidate() {
            cellIdentifierToContentSizeMap = [:]
            cellIdentifierToPreferencesMap = [:]
            cellIdentifierToCacheMap = [:]
            cellIdentifierToIndexPathMap = [:]
            indexPathToContentSizeMap = [:]
            indexPathToCellIdentifierMap = [:]
            
            supplementaryViewIdentifierToContentSizeMap = [:]
            supplementaryViewIdentifierToIndexPathMap = [:]
            indexPathToSupplementaryViewContentSizeMap = [:]
            
            itemIdentifierHashToIndexPathMap = [:]
        }
        
        // MARK: - UICollectionViewDelegateFlowLayout -
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            guard let dataSource = parent.dataSource, dataSource.contains(indexPath) else {
                return .init(width: 1.0, height: 1.0)
            }
            
            let section = parent._unsafelyUnwrappedSection(from: indexPath)
            let sectionIdentifier = parent.dataSourceConfiguration.identifierMap[section]
            let item = parent._unsafelyUnwrappedItem(at: indexPath)
            let itemIdentifier = parent.dataSourceConfiguration.identifierMap[item]
            let id = UICollectionViewCellType.Configuration.ID(item: itemIdentifier, section: sectionIdentifier)
            
            let indexPathBasedSize = indexPathToContentSizeMap[indexPath]
            let identifierBasedSize = cellIdentifierToContentSizeMap[id]
            
            if let size = identifierBasedSize, indexPathBasedSize == nil {
                indexPathToContentSizeMap[indexPath] = size
                return size
            } else if let size = indexPathBasedSize, size == identifierBasedSize {
                return size
            } else {
                invalidateCachedContentSize(forIndexPath: indexPath)
                
                return sizeForItem(
                    atIndexPath: indexPath,
                    withCellConfiguration: .init(
                        item: item,
                        section: section,
                        itemIdentifier: itemIdentifier,
                        sectionIdentifier: sectionIdentifier,
                        indexPath: indexPath,
                        viewProvider: parent.viewProvider,
                        maximumSize: parent.maximumCellSize
                    )
                )
            }
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderOrFooterInSection section: Int,
            kind: String
        ) -> CGSize {
            let indexPath = IndexPath(row: -1, section: section)
            
            guard let dataSource = parent.dataSource, dataSource.contains(indexPath) else {
                return .init(width: 1.0, height: 1.0)
            }
            
            let section = parent._unsafelyUnwrappedSection(from: indexPath)
            let sectionIdentifier = parent.dataSourceConfiguration.identifierMap[section]
            let id = UICollectionViewSupplementaryViewType.Configuration.ID(kind: kind, item: nil, section: sectionIdentifier)
            
            let indexPathBasedSize = indexPathToSupplementaryViewContentSizeMap[kind]?[indexPath]
            let identifierBasedSize = supplementaryViewIdentifierToContentSizeMap[id]
            
            if let size = identifierBasedSize, indexPathBasedSize == nil {
                indexPathToSupplementaryViewContentSizeMap[kind]?[indexPath] = size
                return size
            } else if let size = indexPathBasedSize, size == identifierBasedSize {
                return size
            } else {
                // invalidateCachedContentSize(forIndexPath: indexPath)
                
                return sizeForSupplementaryView(
                    atIndexPath: indexPath,
                    withConfiguration: .init(
                        kind: UICollectionView.elementKindSectionHeader,
                        item: nil,
                        section: section,
                        itemIdentifier: nil,
                        sectionIdentifier: sectionIdentifier,
                        indexPath: indexPath,
                        viewProvider: parent.viewProvider,
                        maximumSize: parent.maximumCellSize
                    )
                )
            }
        }
    }
}

extension UIHostingCollectionViewController.Cache {
    public func cellCache(
        for id: UICollectionViewCellType.Configuration.ID
    ) -> Binding<UICollectionViewCellType.Cache?> {
        .init(
            get: { self.cellIdentifierToCacheMap[id] },
            set: { self.cellIdentifierToCacheMap[id] = $0 }
        )
    }
    
    public func setCellCache(
        _ cache: UICollectionViewCellType.Cache?,
        for id: UICollectionViewCellType.Configuration.ID
    ) {
        cellIdentifierToCacheMap[id] = cache
    }
    
    subscript(preferencesFor id: UIHostingCollectionViewController.UICollectionViewCellType.Configuration.ID) -> UIHostingCollectionViewController.UICollectionViewCellType.Preferences? {
        get {
            cellIdentifierToPreferencesMap[id]
        } set {
            let oldValue = self[preferencesFor: id]
            
            cellIdentifierToPreferencesMap[id] = newValue
            
            guard let indexPath = cellIdentifierToIndexPathMap[id] else {
                return
            }
            
            if oldValue?.relativeFrame != newValue?.relativeFrame {
                parent.cache.invalidateIndexPath(indexPath)
                parent.invalidateLayout(includingCache: false)
            }
        }
    }
    
    public func preferences(itemAt indexPath: IndexPath) -> Binding<UIHostingCollectionViewController.UICollectionViewCellType.Preferences?> {
        .init(
            get: { self.indexPathToCellIdentifierMap[indexPath].flatMap({ self[preferencesFor: $0 ]}) },
            set: { newValue in self.indexPathToCellIdentifierMap[indexPath].map({ self[preferencesFor: $0] = newValue }) }
        )
    }
}

extension UIHostingCollectionViewController.Cache {
    private func sizeForItem(
        atIndexPath indexPath: IndexPath,
        withCellConfiguration cellConfiguration: UIHostingCollectionViewController.UICollectionViewCellType.Configuration
    ) -> CGSize {
        prototypeCell.configuration = cellConfiguration
        
        preconfigure(cell: prototypeCell)
        
        prototypeCell.update(forced: true)
        prototypeCell.cellWillDisplay(inParent: nil, isPrototype: true)
        
        var size = prototypeCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        size.clamp(to: prototypeCell.configuration?.maximumSize ?? nil)
        
        guard !(size.width == 1 && size.height == 1) else {
            return size
        }
        
        cellIdentifierToContentSizeMap[cellConfiguration.id] = size
        cellIdentifierToIndexPathMap[cellConfiguration.id] = indexPath
        indexPathToContentSizeMap[cellConfiguration.indexPath] = size
        indexPathToCellIdentifierMap[cellConfiguration.indexPath] = .init(item: cellConfiguration.itemIdentifier, section: cellConfiguration.sectionIdentifier)
        itemIdentifierHashToIndexPathMap[cellConfiguration.itemIdentifier.hashValue] = indexPath
        
        return size
    }
    
    private func sizeForSupplementaryView(
        atIndexPath indexPath: IndexPath,
        withConfiguration configuration: UIHostingCollectionViewController.UICollectionViewSupplementaryViewType.Configuration
    ) -> CGSize {
        let prototypeView = configuration.kind == UICollectionView.elementKindSectionHeader ? prototypeHeaderView : prototypeFooterView
        
        prototypeView.configuration = configuration
        prototypeView.supplementaryViewWillDisplay(inParent: nil, isPrototype: true)
        
        let size = prototypeView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        guard !(size.width == 1 && size.height == 1) else {
            return size
        }
        
        supplementaryViewIdentifierToContentSizeMap[configuration.id] = size
        supplementaryViewIdentifierToIndexPathMap[configuration.id] = indexPath
        indexPathToSupplementaryViewContentSizeMap[configuration.kind, default: [:]][configuration.indexPath] = size
        
        return size
    }
    
    func invalidateCachedContentSize(forIndexPath indexPath: IndexPath) {
        guard let id = indexPathToCellIdentifierMap[indexPath] else {
            return
        }
        
        cellIdentifierToContentSizeMap[id] = nil
        indexPathToContentSizeMap[indexPath] = nil
    }
    
    func invalidateIndexPath(_ indexPath: IndexPath) {
        invalidateCachedContentSize(forIndexPath: indexPath)
        
        guard let id = indexPathToCellIdentifierMap[indexPath] else {
            return
        }
        
        cellIdentifierToIndexPathMap[id] = nil
        indexPathToCellIdentifierMap[indexPath] = nil
        itemIdentifierHashToIndexPathMap[id.item.hashValue] = nil
    }
    
    func firstIndexPath(for identifier: AnyHashable) -> IndexPath? {
        if let indexPath = itemIdentifierHashToIndexPathMap[identifier.hashValue] {
            return indexPath
        } else {
            return nil
        }
    }
    
    func identifier(for indexPath: IndexPath) -> UIHostingCollectionViewController.UICollectionViewCellType.Configuration.ID? {
        indexPathToCellIdentifierMap[indexPath]
    }
}

#endif
