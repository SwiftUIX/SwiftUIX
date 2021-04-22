//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingCollectionViewController {
    public enum DataSource: CustomStringConvertible {
        public struct IdentifierMap {
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
        
        case diffableDataSource(Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>)
        case `static`(AnyRandomAccessCollection<ListSection<SectionType, ItemType>>)
        
        public var isEmpty: Bool {
            switch self {
                case .diffableDataSource(let dataSource):
                    return (dataSource.wrappedValue?.snapshot().numberOfItems ?? 0) == 0
                case .static(let data):
                    return !data.contains(where: { $0.items.count != 0 })
            }
        }
        
        public var numerOfSections: Int {
            switch self {
                case .diffableDataSource(let dataSource):
                    return dataSource.wrappedValue?.snapshot().numberOfSections ?? 0
                case .static(let data):
                    return data.count
            }
        }
        
        public var numberOfItems: Int {
            switch self {
                case .diffableDataSource(let dataSource):
                    return dataSource.wrappedValue?.snapshot().numberOfItems ?? 0
                case .static(let data):
                    return data.map({ $0.items.count }).reduce(into: 0, +=)
            }
        }
        
        public var description: String {
            switch self {
                case .diffableDataSource(let dataSource):
                    return "Diffable Data Source (\((dataSource.wrappedValue?.snapshot().itemIdentifiers.count).map({ "\($0) items" }) ?? "nil")"
                case .static(let data):
                    return "Static Data \(data.count)"
            }
        }
        
        func contains(_ indexPath: IndexPath) -> Bool {
            switch self {
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
    }
}

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
        
        if case .diffableDataSource(let binding) = newValue {
            DispatchQueue.main.async {
                if binding.wrappedValue !== _internalDataSource {
                    binding.wrappedValue = _internalDataSource
                }
            }
            
            return
        }
        
        guard let oldValue = oldValue else {
            guard case let .static(newData) = newValue, !newData.isEmpty else {
                return
            }
            
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItemsIfNecessary()
            snapshot.appendSections(newData.map({ dataSourceConfiguration.identifierMap[$0.model] }))
            
            for element in newData {
                snapshot.appendItems(
                    element.items.map({ dataSourceConfiguration.identifierMap[$0] }),
                    toSection: dataSourceConfiguration.identifierMap[element.model]
                )
            }
            
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            
            return
        }
        
        guard case let (.static(data), .static(oldData)) = (newValue, oldValue) else {
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            
            return
        }
        
        let oldSections = oldData.map({ $0.model })
        let sections = data.map({ $0.model })
        
        var snapshot = _internalDataSource.snapshot()
        
        let sectionDifference = sections.lazy
            .map({ self.dataSourceConfiguration.identifierMap[$0] })
            .difference(
                from: oldSections.map({ self.dataSourceConfiguration.identifierMap[$0] })
            )
        
        snapshot.applySectionDifference(sectionDifference)
        
        var hasDataSourceChanged: Bool = false
        
        if !sectionDifference.isEmpty {
            hasDataSourceChanged = true
        }
        
        for sectionData in data {
            let section = sectionData.model
            let sectionItems = sectionData.items
            let oldSectionData = oldData.first(where: { self.dataSourceConfiguration.identifierMap[$0.model] == self.dataSourceConfiguration.identifierMap[sectionData.model] })
            let oldSectionItems = oldSectionData?.items ?? AnyRandomAccessCollection([])
            
            let difference = sectionItems.lazy
                .map({ self.dataSourceConfiguration.identifierMap[$0] })
                .difference(from: oldSectionItems.lazy.map { self.dataSourceConfiguration.identifierMap[$0]
                })
            
            if !difference.isEmpty {
                snapshot.applyItemDifference(
                    difference,
                    inSection: self.dataSourceConfiguration.identifierMap[section]
                )
                
                hasDataSourceChanged = true
            }
        }
        
        if hasDataSourceChanged {
            cache.invalidate()

            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
        }
    }
}

// MARK: - Auxiliary Implementation -

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
    ) {
        difference.forEach({ applyItemChange($0, inSection: section) })
    }
    
    mutating func applyItemChange(_ change: CollectionDifference<ItemIdentifierType>.Change, inSection section: SectionIdentifierType) {
        switch change {
            case .insert(itemIdentifiers(inSection: section).count, let element, _):
                appendItems([element], toSection: section)
            case .insert(let offset, let element, _): do {
                let items = itemIdentifiers(inSection: section)
                
                if offset < items.count {
                    insertItems([element], beforeItem: items[offset])
                } else {
                    appendItems([element])
                }
            }
            case .remove(_, let element, _):
                deleteItems([element])
        }
    }
}

#endif
