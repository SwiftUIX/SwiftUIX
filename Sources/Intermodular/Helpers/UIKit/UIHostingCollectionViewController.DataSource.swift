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

#endif
