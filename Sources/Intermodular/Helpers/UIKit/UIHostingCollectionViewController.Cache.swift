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
        typealias UICollectionViewSupplementaryViewType = UIHostingCollectionViewController.UICollectionViewSupplementaryViewType
        
        unowned let parent: UIHostingCollectionViewController
        
        private var cellIdentifierToCacheMap: [UICollectionViewCellType.Configuration.ID: UICollectionViewCellType.Cache] = [:]
        private var cellIdentifierToPreferencesMap: [UICollectionViewCellType.Configuration.ID: UICollectionViewCellType.Preferences] = [:]
        private var cellIdentifierToIndexPathMap: [UICollectionViewCellType.Configuration.ID: IndexPath] = [:]
        private var indexPathToCellIdentifierMap: [IndexPath: UICollectionViewCellType.Configuration.ID] = [:]
        private var supplementaryViewIdentifierToCacheMap: [UICollectionViewSupplementaryViewType.Configuration.ID: UICollectionViewSupplementaryViewType.Cache] = [:]
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
        
        func preconfigure(supplementaryView: UICollectionViewSupplementaryViewType) {
            supplementaryView.cache = .init()
            
            guard let id = supplementaryView.configuration?.id else {
                return
            }
            
            if let supplementaryViewCache = supplementaryViewIdentifierToCacheMap[id] {
                supplementaryView.cache = supplementaryViewCache
            }
        }
        
        func invalidate() {
            cellIdentifierToCacheMap = [:]
            cellIdentifierToPreferencesMap = [:]
            cellIdentifierToIndexPathMap = [:]
            
            indexPathToCellIdentifierMap = [:]
            
            supplementaryViewIdentifierToCacheMap = [:]
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
            
            if let size = cellIdentifierToCacheMap[id]?.contentSize {
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
                        maximumSize: parent.maximumCollectionViewCellSize
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
                        maximumSize: parent.maximumCollectionViewCellSize
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
    
    public func setSupplementaryViewCache(
        _ cache: UICollectionViewSupplementaryViewType.Cache?,
        for id: UICollectionViewSupplementaryViewType.Configuration.ID
    ) {
        supplementaryViewIdentifierToCacheMap[id] = cache
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
                parent.invalidateLayout(includingCache: false, animated: false)
            }
        }
    }
    
    public func preferences(
        forID id: UIHostingCollectionViewController.UICollectionViewCellType.Configuration.ID
    ) -> Binding<UIHostingCollectionViewController.UICollectionViewCellType.Preferences?> {
        .init(
            get: { [weak self] in
                guard let `self` = self else {
                    return nil
                }
                
                return self.cellIdentifierToPreferencesMap[id]
            },
            set: { [weak self] newValue in
                guard let `self` = self else {
                    return
                }
                
                let oldValue = self.cellIdentifierToPreferencesMap[id]
                
                self.cellIdentifierToPreferencesMap[id] = newValue
                
                guard let indexPath = self.cellIdentifierToIndexPathMap[id] else {
                    return
                }
                
                if oldValue?.relativeFrame != newValue?.relativeFrame {
                    self.parent.cache.invalidateIndexPath(indexPath)
                    self.parent.invalidateLayout(includingCache: false, animated: false)
                }
            }
        )
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
        withCellConfiguration configuration: UIHostingCollectionViewController.UICollectionViewCellType.Configuration
    ) -> CGSize {
        prototypeCell.configuration = configuration
        
        preconfigure(cell: prototypeCell)
        
        prototypeCell.update(disableAnimation: true)
        prototypeCell.cellWillDisplay(inParent: nil, isPrototype: true)
        
        let size = prototypeCell
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .clamped(to: (prototypeCell.configuration?.maximumSize ?? nil).rounded(.down))
        
        guard !(size.width == 1 && size.height == 1) else {
            return size
        }
        
        prototypeCell.cache.contentSize = size
        
        cellIdentifierToCacheMap[configuration.id]?.contentSize = size
        cellIdentifierToIndexPathMap[configuration.id] = indexPath
        indexPathToCellIdentifierMap[configuration.indexPath] = configuration.id
        itemIdentifierHashToIndexPathMap[configuration.itemIdentifier.hashValue] = indexPath
        
        return size
    }
    
    private func sizeForSupplementaryView(
        atIndexPath indexPath: IndexPath,
        withConfiguration configuration: UIHostingCollectionViewController.UICollectionViewSupplementaryViewType.Configuration
    ) -> CGSize {
        let prototypeView = configuration.kind == UICollectionView.elementKindSectionHeader ? prototypeHeaderView : prototypeFooterView
        
        prototypeView.configuration = configuration
        
        preconfigure(cell: prototypeCell)
        
        prototypeView.update(disableAnimation: true)
        prototypeView.supplementaryViewWillDisplay(inParent: nil, isPrototype: true)
        
        let size = prototypeView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .clamped(to: configuration.maximumSize?.rounded(.down))
        
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
        
        cellIdentifierToCacheMap[id]?.contentSize = nil
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
