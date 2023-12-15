//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

extension _CollectionView {
    struct DataSource {
        typealias UICollectionViewDiffableDataSourceType = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
        
        let configuration: Configuration
        let payload: UIViewControllerType.DataSource.Payload
    }
}

extension _CollectionView.DataSource {
    struct Configuration {
        struct IdentifierMap {
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
            
            subscript(_ itemID: ItemIdentifierType) -> ItemType {
                getItemFromID(itemID)
            }
        }
        
        let identifierMap: IdentifierMap
    }
    
    enum Payload {
        case diffableDataSource(Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>)
        case `static`(AnyRandomAccessCollection<ListSection<SectionType, ItemType>>)
    }
}

extension _CollectionView.DataSource.Payload: CustomStringConvertible {
    var isEmpty: Bool {
        switch self {
            case .diffableDataSource(let dataSource):
                return (dataSource.wrappedValue?.snapshot().numberOfItems ?? 0) == 0
            case .static(let data):
                return !data.contains(where: { $0.items.count != 0 })
        }
    }
    
    var numberOfSections: Int {
        switch self {
            case .diffableDataSource(let dataSource):
                return dataSource.wrappedValue?.snapshot().numberOfSections ?? 0
            case .static(let data):
                return data.count
        }
    }
    
    var numberOfItems: Int {
        switch self {
            case .diffableDataSource(let dataSource):
                return dataSource.wrappedValue?.snapshot().numberOfItems ?? 0
            case .static(let data):
                return data.map({ $0.items.count }).reduce(into: 0, +=)
        }
    }
    
    var description: String {
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
    
    func reset(
        _ diffableDataSource: _CollectionView.DataSource.UICollectionViewDiffableDataSourceType,
        withConfiguration configuration: _CollectionView.DataSource.Configuration,
        animatingDifferences: Bool
    ) {
        guard case .static(let data) = self else {
            return
        }
        
        var snapshot = diffableDataSource.snapshot()
        
        snapshot.deleteAllItemsIfNecessary()
        snapshot.appendSections(data.map({ configuration.identifierMap[$0.model] }))
        
        for element in data {
            snapshot.appendItems(
                element.items.map({ configuration.identifierMap[$0] }),
                toSection: configuration.identifierMap[element.model]
            )
        }
        
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension CocoaHostingCollectionViewController {
    func updateDataSource(
        oldValue: DataSource.Payload?,
        newValue: DataSource.Payload?
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
            
            newValue?.reset(
                _internalDataSource,
                withConfiguration: dataSourceConfiguration,
                animatingDifferences: false
            )
            
            if _scrollViewConfiguration.initialContentAlignment == .bottom {
                scrollToLast(animated: false)
            }
            
            return
        }
        
        guard case let (.static(data), .static(oldData)) = (newValue, oldValue) else {
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            performEnforcingScrollOffsetBehavior(animated: _animateDataSourceDifferences) {
                _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            }
            
            return
        }
        
        let oldSections: [SectionType] = oldData.map({ $0.model })
        let sections: [SectionType] = data.map({ $0.model })
        
        var snapshot = _internalDataSource.snapshot()
        
        let sectionDifference: CollectionDifference<SectionIdentifierType> = sections
            .map {
                self.dataSourceConfiguration.identifierMap[$0]
            }
            .difference(
                from: oldSections.map {
                    self.dataSourceConfiguration.identifierMap[$0]
                }
            )
        
        snapshot.applySectionDifference(sectionDifference)
        
        var hasDataSourceChanged: Bool = false
        
        if !sectionDifference.isEmpty {
            hasDataSourceChanged = true
        }
        
        for sectionData in data {
            let section = sectionData.model
            let sectionItems = sectionData.items
            
            let oldSectionData = oldData.first(where: {
                let sectionID: SectionIdentifierType = self.dataSourceConfiguration.identifierMap[sectionData.model]
                
                return self.dataSourceConfiguration.identifierMap[$0.model] == sectionID
            })
            
            let oldSectionItems = oldSectionData?.items ?? AnyRandomAccessCollection([])
            
            let difference: CollectionDifference<ItemIdentifierType> = sectionItems
                .map {
                    self.dataSourceConfiguration.identifierMap[$0]
                }
                .difference(
                    from: oldSectionItems.map {
                        self.dataSourceConfiguration.identifierMap[$0]
                    }
                )
            
            if !difference.isEmpty {
                let sectionIdentifier = self.dataSourceConfiguration.identifierMap[section]
                
                if !snapshot.sectionIdentifiers.contains(sectionIdentifier) {
                    snapshot.appendSections([sectionIdentifier])
                }
                
                let itemDifferencesApplied = snapshot.applyItemDifference(
                    difference,
                    inSection: sectionIdentifier
                )
                
                if !itemDifferencesApplied {
                    performEnforcingScrollOffsetBehavior(animated: _animateDataSourceDifferences) {
                        newValue?.reset(
                            _internalDataSource,
                            withConfiguration: dataSourceConfiguration,
                            animatingDifferences: _animateDataSourceDifferences
                        )
                    }
                }
                
                hasDataSourceChanged = true
            }
        }
        
        if hasDataSourceChanged {
            cache.invalidate()
            
            performEnforcingScrollOffsetBehavior(animated: _animateDataSourceDifferences) {
                _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            }
        }
    }
    
    private func performEnforcingScrollOffsetBehavior(
        animated: Bool,
        perform operaton: () -> Void
    ) {
        collectionView.performEnforcingScrollOffsetBehavior(
            _scrollViewConfiguration.contentOffsetBehavior,
            animated: animated
        ) {
            operaton()
        }
    }
}

// MARK: - Auxiliary

fileprivate extension NSDiffableDataSourceSnapshot {
    mutating func deleteAllItemsIfNecessary() {
        if itemIdentifiers.count > 0 || sectionIdentifiers.count > 0 {
            deleteAllItems()
        }
    }
    
    mutating func applySectionDifference(
        _ difference: CollectionDifference<SectionIdentifierType>
    ) {
        difference.forEach({ applySectionChanges($0) })
    }
    
    mutating func applySectionChanges(
        _ change: CollectionDifference<SectionIdentifierType>.Change
    ) {
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
        difference.allSatisfy { applyItemChange($0, inSection: section) }
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
