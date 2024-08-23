//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A model suitable for representing sections of a list.
@_documentation(visibility: internal)
public struct ListSection<SectionType, ItemType> {
    enum _ItemsStorage {
        case array([ItemType])
        case collection(AnyRandomAccessCollection<ItemType>)
    }
    
    public typealias Items = AnyRandomAccessCollection<ItemType>
    
    private let _model: SectionType?
    
    public var model: SectionType {
        _model!
    }
    
    public let items: AnyRandomAccessCollection<ItemType>
    
    public subscript(_ index: Int) -> ItemType {
        get {
            items[items.index(items.startIndex, offsetBy: index)]
        }
    }
    
    public init<Items: RandomAccessCollection>(
        _ model: SectionType,
        items: Items
    ) where Items.Element == ItemType  {
        self._model = model
        self.items = .init(items)
    }
    
    public init(
        _ model: SectionType,
        items: AnyRandomAccessCollection<ItemType>
    ) {
        self._model = model
        self.items = .init(items)
    }
    
    public init(
        _ model: SectionType,
        @_ArrayBuilder<ItemType> items: () -> [ItemType]
    ) {
        self.init(model, items: items())
    }
}

extension ListSection {
    public func map<T>(
        _ transform: (SectionType) -> T
    ) -> ListSection<T, ItemType> {
        ListSection<T, ItemType>(
            transform(self.model),
            items: items
        )
    }
    
    public func mapItems<T>(
        _ transform: (ItemType) -> T
    ) -> ListSection<SectionType, T> {
        ListSection<SectionType, T>(
            self.model,
            items: items.map(transform)
        )
    }
}

extension ListSection where SectionType: Equatable {
    public static func == (lhs: Self, rhs: SectionType) -> Bool {
        lhs.model == rhs
    }
    
    public static func == (lhs: SectionType, rhs: Self) -> Bool {
        rhs.model == lhs
    }
    
    public static func != (lhs: Self, rhs: SectionType) -> Bool {
        !(lhs == rhs)
    }
    
    public static func != (lhs: SectionType, rhs: Self) -> Bool {
        !(lhs == rhs)
    }
}

extension ListSection where SectionType: Identifiable, ItemType: Identifiable {
    public init<Items: RandomAccessCollection>(
        model: SectionType,
        items: Items
    ) where Items.Element == ItemType {
        self._model = model
        self.items = .init(items)
    }
    
    public init(
        model: SectionType,
        items: AnyRandomAccessCollection<ItemType>
    ) {
        self._model = model
        self.items = items
    }
}

extension ListSection where SectionType: Identifiable, ItemType: Identifiable {
    public func isIdentical(to other: Self) -> Bool {
        guard items.count == other.items.count else {
            return false
        }
        
        if SectionType.self != Never.self {
            guard model.id == other.model.id else {
                return false
            }
        }
        
        for (item, otherItem) in zip(items, other.items) {
            guard item.id == otherItem.id else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Conformances

extension ListSection: Equatable where SectionType: Equatable, ItemType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if SectionType.self == Never.self {
            return Array<ItemType>(lhs.items) == Array<ItemType>(rhs.items)
        } else {
            return (lhs.model == rhs.model) && (Array<ItemType>(lhs.items) == Array<ItemType>(rhs.items))
        }
    }
}

extension ListSection: Comparable where SectionType: Comparable, ItemType: Equatable {
    public static func < (lhs: ListSection, rhs: ListSection) -> Bool {
        lhs.model < rhs.model
    }
}

extension ListSection: Hashable where SectionType: Hashable, ItemType: Hashable {
    public func hash(into hasher: inout Hasher) {
        if SectionType.self != Never.self {
            hasher.combine(model)
        }
        
        items.forEach({ hasher.combine($0) })
    }
}

extension ListSection: Identifiable where SectionType: Identifiable, ItemType: Identifiable {
    public var id: Int {
        var hasher = Hasher()
        
        if SectionType.self != Never.self {
            hasher.combine(model.id)
        }
        
        items.forEach({ hasher.combine($0.id) })
        
        return hasher.finalize()
    }
}

// MARK: - Helpers

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Collection {
    subscript<SectionType, ItemType>(
        _ indexPath: IndexPath
    ) -> ItemType where Element == ListSection<SectionType, ItemType> {
        get {
            let sectionIndex = index(startIndex, offsetBy: indexPath.section)
            
            let rowIndex = self[sectionIndex]
                .items
                .index(self[sectionIndex].items.startIndex, offsetBy: indexPath.row)
            
            return self[sectionIndex].items[rowIndex]
        }
    }
    
    subscript<SectionType, ItemType>(
        try indexPath: IndexPath
    ) -> ItemType? where Element == ListSection<SectionType, ItemType> {
        get {
            let sectionIndex = index(startIndex, offsetBy: indexPath.section)
            
            let rowIndex = self[sectionIndex]
                .items
                .index(self[sectionIndex].items.startIndex, offsetBy: indexPath.row)
            
            return self[sectionIndex].items[rowIndex]
        }
    }
}
#endif
    
extension Collection {
    public func isIdentical<SectionModel: Identifiable, Item: Identifiable>(
        to other: Self
    ) -> Bool where Element == ListSection<SectionModel, Item> {
        guard count == other.count else {
            return false
        }
        
        for (element, otherElement) in Swift.zip(self, other) {
            guard element.isIdentical(to: otherElement) else {
                return false
            }
        }
        
        return true
    }
}
