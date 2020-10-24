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
    
    public let data: AnyRandomAccessCollection<Item>
    
    public init(
        model: Model,
        data: [Item]
    ) {
        self._id = nil
        self._model = model
        self.data = .init(data)
    }
    
    public init(
        model: Model,
        items: [Item]
    ) {
        self.init(model: model, data: items)
    }
    
    public init(
        _ model: Model,
        @ArrayBuilder<Item> data: () -> [Item]
    ) {
        self.init(model: model, data: data())
    }
}

extension ListSection where Model: Equatable {
    public static func == (lhs: Self, rhs: Model) -> Bool {
        lhs.model == rhs
    }
    
    public static func == (lhs: Model, rhs: Self) -> Bool {
        rhs.model == lhs
    }
    
    public static func != (lhs: Self, rhs: Model) -> Bool {
        !(lhs == rhs)
    }
    
    public static func != (lhs: Model, rhs: Self) -> Bool {
        !(lhs == rhs)
    }
}

extension ListSection where Model: Identifiable, Item: Identifiable {
    public init(
        model: Model,
        data: [Item]
    ) {
        self._model = model
        self.data = .init(data)
        
        var hasher = Hasher()
        
        if Model.self != Never.self {
            hasher.combine(model.id)
        }
        
        data.forEach {
            hasher.combine($0.id)
        }
        
        self._id = hasher.finalize()
    }
}

extension ListSection where Model == Never {
    public init(items: [Item]) {
        self._id = nil
        self._model = nil
        self.data = .init(items)
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
            guard data.count == other.data.count else {
                return false
            }
            
            if Model.self != Never.self {
                guard model.id == other.model.id else {
                    return false
                }
            }
            
            for (item, otherItem) in zip(data, other.data) {
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
            return Array(lhs.data) == Array(rhs.data)
        } else {
            return lhs.model == rhs.model && Array(lhs.data) == Array(rhs.data)
        }
    }
}

extension ListSection: Hashable where Model: Hashable, Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        if Model.self != Never.self {
            hasher.combine(model)
        }
        
        data.forEach({ hasher.combine($0) })
    }
}

extension ListSection: Identifiable where Model: Identifiable, Item: Identifiable {
    public var id: Int {
        var hasher = Hasher()
        
        if Model.self != Never.self {
            hasher.combine(model.id)
        }
        
        data.forEach({ hasher.combine($0.id) })
        
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
                .data
                .index(self[sectionIndex].data.startIndex, offsetBy: indexPath.row)
            
            return self[sectionIndex].data[rowIndex]
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
