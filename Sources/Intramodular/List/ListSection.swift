//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A model suitable for representing sections of a list.
public struct ListSection<Model, Item> {
    private let _id: Int?
    private let _model: Model!
    
    public var model: Model {
        _model
    }
    
    public let items: [Item]
    
    public init(
        model: Model,
        items: [Item]
    ) {
        self._id = nil
        self._model = model
        self.items = items
    }
}

extension ListSection where Model: Identifiable, Item: Identifiable {
    public init(
        model: Model,
        items: [Item]
    ) {
        self._model = model
        self.items = items
        
        var hasher = Hasher()
        
        if Model.self != Never.self {
            hasher.combine(model.id)
        }
        
        items.forEach {
            hasher.combine($0.id)
        }
        
        self._id = hasher.finalize()
    }
}

extension ListSection where Model == Never {
    public init(items: [Item]) {
        self._id = nil
        self._model = nil
        self.items = items
    }
    
    public init<C: Collection>(items: C) where C.Element == Item {
        self.init(items: Array(items))
    }
}

extension ListSection where Model: Identifiable, Item: Identifiable {
    public func isIdentical(to other: Self) -> Bool {
        if let id = _id, let otherId = other._id {
            return id == otherId
        } else {
            guard items.count == other.items.count else {
                return false
            }
            
            if Model.self != Never.self {
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
}

// MARK: - Protocol Implementations -

extension ListSection: Equatable where Model: Equatable, Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if Model.self == Never.self {
            return lhs.items == rhs.items
        } else {
            return lhs.model == rhs.model && lhs.items == rhs.items
        }
    }
}

extension ListSection: Hashable where Model: Hashable, Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        if Model.self != Never.self {
            hasher.combine(model)
        }
        
        hasher.combine(items)
    }
}

extension ListSection: Identifiable where Model: Identifiable, Item: Identifiable {
    public var id: Int {
        var hasher = Hasher()
        
        if Model.self != Never.self {
            hasher.combine(model.id)
        }
        
        items.forEach({ hasher.combine($0.id) })
        
        return hasher.finalize()
    }
}

// MARK: - Helpers -

extension Collection  {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    subscript<SectionModel, Item>(_ indexPath: IndexPath) -> Item where Element == ListSection<SectionModel, Item> {
        get {
            let sectionIndex = index(startIndex, offsetBy: indexPath.section)
            let rowIndex = self[sectionIndex]
                .items
                .index(self[sectionIndex].items.startIndex, offsetBy: indexPath.row)
            
            return self[sectionIndex].items[rowIndex]
        }
    }
    #endif
    
    public func isIdentical<SectionModel: Identifiable, Item: Identifiable>(to other: Self) -> Bool where Element == ListSection<SectionModel, Item> {
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
