//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A model suitable for representing sections of a list.
public struct ListSection<SectionType, ItemType> {
    public typealias Items = AnyRandomAccessCollection<ItemType>
    
    private let _model: SectionType?
    
    public var model: SectionType {
        _model!
    }
    
    public let items: AnyRandomAccessCollection<ItemType>
    
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
        @ArrayBuilder<ItemType> items: () -> [ItemType]
    ) {
        self.init(model, items: items())
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

// MARK: - Conformances -

extension ListSection: Equatable where SectionType: Equatable, ItemType: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if SectionType.self == Never.self {
            return Array(lhs.items) == Array(rhs.items)
        } else {
            return lhs.model == rhs.model && Array(lhs.items) == Array(rhs.items)
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

// MARK: - Helpers -

extension Collection {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
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
    #endif
    
    public func isIdentical<SectionModel: Identifiable, Item: Identifiable>(
        to other: Self
    ) -> Bool where Element == ListSection<SectionModel, Item> {
        guard count == other.count else {
            return false
        }
        
        for (element, otherElement) in zip(self, other) {
            guard element.isIdentical(to: otherElement) else {
                return false
            }
        }
        
        return true
    }
}
