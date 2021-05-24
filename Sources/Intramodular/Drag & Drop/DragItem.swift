//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A representation of an underlying data item being dragged from one location to another.
public struct DragItem: Hashable {
    public final class PreferenceKey: TakeLastPreferenceKey<[DragItem]> {
        
    }
    
    public let id: AnyHashable
    public let base: Any?
    public let itemProvider: NSItemProvider
    
    public var localItem: Any? {
        base
    }
    
    @_disfavoredOverload
    public init<Item: Identifiable>(_ base: Item) {
        self.id = base.id
        self.base = base
        self.itemProvider = NSItemProvider()
    }
    
    public init<Item: Codable & Hashable>(_ base: Item) {
        self.id = base.hashValue
        self.base = base
        self.itemProvider = NSItemProvider(object: AnyCodableItemProvider(item: base))
    }
    
    public init<Item: NSSecureCoding & NSItemProviderWriting, ID: Hashable>(
        _ base: Item,
        id: ID
    ) {
        self.id = id
        self.base = base
        self.itemProvider = NSItemProvider()
        
        itemProvider.registerObject(base, visibility: .all)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension DragItem {
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public init(_ base: String) {
        self.id = base
        self.base = base
        self.itemProvider = .init(
            item: base as NSString,
            typeIdentifier: UTType.text.identifier
        )
    }
}

extension View {
    public func dragItems(_ items: [DragItem]) -> some View {
        preference(key: DragItem.PreferenceKey.self, value: items)
    }
}

// MARK: - Auxiliary Implementation -

private final class AnyCodableItemProvider<Item: Codable & Hashable>: NSObject, NSItemProviderReading, NSItemProviderWriting {
    enum EncodingError: Error {
        case invalidData
    }
    
    let item: Item
    
    override var hash: Int {
        item.hashValue
    }
    
    init(item: Item) {
        self.item = item
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let itemData = aDecoder.decodeObject(forKey: "item") as? Data else {
            return nil
        }
        
        guard let item = try? PropertyListDecoder().decode(Item.self, from: itemData) else {
            return nil
        }
        
        self.init(item: item)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(try? PropertyListEncoder().encode(item), forKey: "item")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? AnyCodableItemProvider<Item> else {
            return false
        }
        
        return self.item == object.item
    }
    
    // MARK: - NSItemProviderReading -
    
    public static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> Self {
        guard Self.readableTypeIdentifiersForItemProvider.contains(typeIdentifier) else {
            throw EncodingError.invalidData
        }
        
        return .init(item: try PropertyListDecoder().decode(Item.self, from: data))
    }
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        writableTypeIdentifiersForItemProvider
    }
    
    // MARK: - NSItemProviderWriting -
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        ["com.vmanot.dragitem-\(Item.self)"]
    }
    
    public func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        if Self.writableTypeIdentifiersForItemProvider.contains(typeIdentifier) {
            do {
                try completionHandler(PropertyListEncoder().encode(item), nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        
        return nil
    }
}

@available(tvOS, unavailable)
extension UIDragItem {
    public convenience init(_ item: DragItem) {
        self.init(itemProvider: item.itemProvider)
        
        localObject = item.base
    }
}

@available(tvOS, unavailable)
extension DragItem {
    public init(_ item: UIDragItem) {
        self.id = item.itemProvider.registeredTypeIdentifiers
        self.base = item.localObject
        self.itemProvider = item.itemProvider
    }
}

#endif
