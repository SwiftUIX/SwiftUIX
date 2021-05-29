//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

extension UIHostingCollectionViewController {
    struct DataSource {
        typealias UICollectionViewDiffableDataSourceType = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
        
        public enum Payload {
            typealias UICollectionViewDiffableDataSourceType = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
            
            case diffableDataSource(Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>)
            case `static`(AnyRandomAccessCollection<ListSection<SectionType, ItemType>>)
        }
        
        struct IdentifierMap {
            typealias UICollectionViewDiffableDataSourceType = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
            
            var getSectionID: (SectionType) -> SectionIdentifierType
            var getSectionFromID: (SectionIdentifierType) -> SectionType
            var getItemID: (ItemType) -> ItemIdentifierType
            var getItemFromID: (ItemIdentifierType) -> ItemType
            
            subscript(_ section: SectionType) -> SectionIdentifierType {
                getSectionID(section)
            }
            
            subscript(_ sectionIdentifier: SectionIdentifierType) -> SectionType {
                getSectionFromID(sectionIdentifier)
            }
            
            subscript(_ item: ItemType) -> ItemIdentifierType {
                getItemID(item)
            }
            
            subscript(_ item: ItemType?) -> ItemIdentifierType? {
                item.map({ self[$0] })
            }
            
            subscript(_ itemID: ItemIdentifierType) -> ItemType {
                getItemFromID(itemID)
            }
        }
        
        let payload: Payload
        let identifierMap: IdentifierMap
    }
}

extension UIHostingCollectionViewController.DataSource {
    var isEmpty: Bool {
        switch payload {
            case .diffableDataSource(let dataSource):
                return (dataSource.wrappedValue?.snapshot().numberOfItems ?? 0) == 0
            case .static(let data):
                return !data.contains(where: { $0.items.count != 0 })
        }
    }
    
    var numerOfSections: Int {
        switch payload {
            case .diffableDataSource(let dataSource):
                return dataSource.wrappedValue?.snapshot().numberOfSections ?? 0
            case .static(let data):
                return data.count
        }
    }
    
    var numberOfItems: Int {
        switch payload {
            case .diffableDataSource(let dataSource):
                return dataSource.wrappedValue?.snapshot().numberOfItems ?? 0
            case .static(let data):
                return data.map({ $0.items.count }).reduce(into: 0, +=)
        }
    }
    
    var description: String {
        switch payload {
            case .diffableDataSource(let dataSource):
                return "Diffable Data Source (\((dataSource.wrappedValue?.snapshot().itemIdentifiers.count).map({ "\($0) items" }) ?? "nil")"
            case .static(let data):
                return "Static Data \(data.count)"
        }
    }
    
    func contains(_ indexPath: IndexPath) -> Bool {
        switch payload {
            case .static(let data): do {
                guard indexPath.section < data.count else {
                    return false
                }
                
                let section = data[data.index(data.startIndex, offsetBy: indexPath.section)]
                
                guard indexPath.row < section.items.count else {
                    return false
                }
                
                return true
            }
            
            case .diffableDataSource(let dataSource): do {
                guard let dataSource = dataSource.wrappedValue else {
                    return false
                }
                
                let snapshot = dataSource.snapshot()
                
                guard indexPath.section < snapshot.numberOfSections else {
                    return false
                }
                
                guard indexPath.row < snapshot.numberOfItems(inSection: snapshot.sectionIdentifiers[indexPath.section]) else {
                    return false
                }
                
                return true
            }
        }
    }
    
    func reset(_ dataSource: UICollectionViewDiffableDataSourceType, animated: Bool) {
        guard case .static(let data) = payload else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItemsIfNecessary()
        snapshot.appendSections(data.map({ identifierMap[$0.model] }))
        
        for element in data {
            snapshot.appendItems(
                element.items.map({ identifierMap[$0] }),
                toSection: identifierMap[element.model]
            )
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewController {
    func updateDataSource(
        oldValue: DataSource?,
        newValue: DataSource?
    ) {
        if configuration.disableAnimatingDifferences {
            _animateDataSourceDifferences = false
        }
        
        defer {
            _animateDataSourceDifferences = true
        }
        
        guard let _internalDataSource = _internalDiffableDataSource else {
            return
        }
        
        if case .diffableDataSource(let binding) = newValue?.payload {
            DispatchQueue.main.async {
                if binding.wrappedValue !== _internalDataSource {
                    binding.wrappedValue = _internalDataSource
                }
            }
            
            return
        }
        
        guard let oldValue = oldValue else {
            guard case let .static(newData) = newValue?.payload, !newData.isEmpty else {
                return
            }
            
            newValue?.reset(_internalDataSource, animated: false)
            
            if _scrollViewConfiguration.initialContentAlignment == .bottom {
                scrollToLast(animated: false)
            }
            
            return
        }
        
        guard case let (.static(data), .static(oldData)) = (newValue?.payload, oldValue.payload) else {
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            maintainScrollContentOffsetBehavior {
                _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            }
            
            return
        }
        
        let oldSections = oldData.map({ $0.model })
        let sections = data.map({ $0.model })
        
        var snapshot = _internalDataSource.snapshot()
        
        let sectionDifference = sections.lazy
            .map({ self.dataSource.identifierMap[$0] })
            .difference(from: oldSections.map({ self.dataSource.identifierMap[$0] }))
        
        snapshot.applySectionDifference(sectionDifference)
        
        var hasDataSourceChanged: Bool = false
        
        if !sectionDifference.isEmpty {
            hasDataSourceChanged = true
        }
        
        for sectionData in data {
            let section = sectionData.model
            let sectionItems = sectionData.items
            let oldSectionData = oldData.first(where: { self.dataSource.identifierMap[$0.model] == self.dataSource.identifierMap[sectionData.model] })
            let oldSectionItems = oldSectionData?.items ?? AnyRandomAccessCollection([])
            
            let difference = sectionItems.lazy
                .map({ self.dataSource.identifierMap[$0] })
                .difference(from: oldSectionItems.lazy.map { self.dataSource.identifierMap[$0]
                })
            
            if !difference.isEmpty {
                let sectionIdentifier = self.dataSource.identifierMap[section]
                
                if !snapshot.sectionIdentifiers.contains(sectionIdentifier) {
                    snapshot.appendSections([sectionIdentifier])
                }
                
                let itemDifferencesApplied = snapshot.applyItemDifference(difference, inSection: sectionIdentifier)
                
                if !itemDifferencesApplied {
                    maintainScrollContentOffsetBehavior {
                        newValue?.reset(_internalDataSource, animated: _animateDataSourceDifferences)
                    }
                }
                
                hasDataSourceChanged = true
            }
        }
        
        if hasDataSourceChanged {
            cache.invalidate()
            
            maintainScrollContentOffsetBehavior {
                _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            }
        }
    }
    
    private func maintainScrollContentOffsetBehavior(_ update: () -> Void) {
        collectionView.maintainScrollContentOffsetBehavior(_scrollViewConfiguration.contentOffsetBehavior, animated: false) {
            update()
        }
    }
}

fileprivate extension CollectionDifference where ChangeElement: Equatable {
    var singleItemReorder: (source: Int, target: Int)? {
        guard count == 2 else {
            return nil
        }
        
        guard case .remove(let sourceOffset, let removedElement, _) = first(where: {
            if case .remove = $0 {
                return true
            } else {
                return false
            }
        }) else {
            return nil
        }
        
        guard case .insert(var targetOffset, let insertedElement, _) = first(where: {
            if case .insert = $0 {
                return true
            } else {
                return false
            }
        }) else {
            return nil
        }
        
        guard insertedElement == removedElement else {
            return nil
        }
        
        if sourceOffset < targetOffset {
            targetOffset += 1
        }
        
        return (sourceOffset, targetOffset)
    }
}

fileprivate extension NSDiffableDataSourceSnapshot {
    mutating func deleteAllItemsIfNecessary() {
        if itemIdentifiers.count > 0 || sectionIdentifiers.count > 0 {
            deleteAllItems()
        }
    }
    
    mutating func applySectionDifference(_ difference: CollectionDifference<SectionIdentifierType>) {
        difference.forEach({ applySectionChanges($0) })
    }
    
    mutating func applySectionChanges(_ change: CollectionDifference<SectionIdentifierType>.Change) {
        switch change {
            case .insert(offset: sectionIdentifiers.count, let element, _):
                appendSections([element])
            case .insert(let offset, let element, _):
                insertSections([element], beforeSection: sectionIdentifiers[offset])
            case .remove(_, let element, _):
                deleteSections([element])
        }
    }
    
    mutating func applyItemDifference(
        _ difference: CollectionDifference<ItemIdentifierType>, inSection section: SectionIdentifierType
    ) -> Bool {
        difference
            .map({ applyItemChange($0, inSection: section) })
            .reduce(true, { $0 && $1 })
    }
    
    mutating func applyItemChange(
        _ change: CollectionDifference<ItemIdentifierType>.Change,
        inSection section: SectionIdentifierType
    ) -> Bool {
        switch change {
            case .insert(itemIdentifiers(inSection: section).count, let element, _):
                appendItems([element], toSection: section)
            case .insert(let offset, let element, _): do {
                let items = itemIdentifiers(inSection: section)
                
                if offset < items.count {
                    guard sectionIdentifier(containingItem: items[offset]) != nil else {
                        print("This should be impossible, but UIKit /shrug")
                        
                        return false
                    }
                    
                    insertItems([element], beforeItem: items[offset])
                } else {
                    appendItems([element])
                }
            }
            case .remove(_, let element, _):
                deleteItems([element])
        }
        
        return true
    }
}

#endif
