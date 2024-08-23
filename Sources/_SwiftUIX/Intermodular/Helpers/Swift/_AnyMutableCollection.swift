//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

// Type-erasing wrapper structure for mutable collections
@_documentation(visibility: internal)
public struct _AnyMutableCollection<Element>: MutableCollection {
    public typealias Index = _AnyMutableCollectionIndex
    
    private var box: AnyCollectionBox<Element>
    
    public init<C: MutableCollection>(_ collection: C) where C.Element == Element {
        box = Box(collection)
    }
    
    public var startIndex: Index {
        box.startIndex
    }
    
    public var endIndex: Index {
        box.endIndex
    }
    
    public func index(after i: Index) -> Index {
        box.index(after: i)
    }
    
    public subscript(position: Index) -> Element {
        get {
            box.getElement(at: position)
        }
        set {
            ensureUniqueBox()
            box.setElement(newValue, at: position)
        }
    }
    
    private mutating func ensureUniqueBox() {
        if !isKnownUniquelyReferenced(&box) {
            box = box.copy() as! AnyCollectionBox<Element>
        }
    }
}

@_documentation(visibility: internal)
public struct _AnyMutableCollectionIndex: Comparable {
    public let base: Any
    
    private let equals: (Any) -> Bool
    private let lessThan: (Any) -> Bool
    
    init<I: Comparable>(_ base: I) {
        self.base = base
        self.equals = { ($0 as! I) == base }
        self.lessThan = { base < ($0 as! I) }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.equals(rhs.base)
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.lessThan(rhs.base)
    }
}

// MARK: - Internal

// Base class for type erasure that operates on elements of type Element
private class AnyCollectionBox<Element>: NSCopying {
    typealias Index = _AnyMutableCollectionIndex
    
    var startIndex: Index {
        fatalError("Must override")
    }
    
    var endIndex: Index {
        fatalError("Must override")
    }
    
    func index(after i: Index) -> Index {
        fatalError("Must override")
    }
    
    func getElement(at index: Index) -> Element {
        fatalError("Must override")
    }
    
    func setElement(_ element: Element, at index: Index) {
        fatalError("Must override")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        fatalError("Must override")
    }
}

// Concrete subclass of AnyCollectionBox for specific collection types
private final class Box<Base: MutableCollection>: AnyCollectionBox<Base.Element> {
    private var base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override var startIndex: Index {
        Index(base.startIndex)
    }
    
    override var endIndex: Index {
        Index(base.endIndex)
    }
    
    override func index(
        after i: Index
    ) -> Index {
        guard let concreteIndex = i.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return Index(base.index(after: concreteIndex))
    }
    
    override func getElement(
        at index: Index
    ) -> Base.Element {
        guard let concreteIndex = index.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return base[concreteIndex]
    }
    
    override func setElement(
        _ element: Base.Element,
        at index: Index
    ) {
        guard let concreteIndex = index.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        base[concreteIndex] = element
    }
    
    override func copy(
        with zone: NSZone? = nil
    ) -> Any {
        return Box(base)
    }
}

// MARK: - Supplementary

extension Binding {
    public init<Data: MutableCollection & RandomAccessCollection>(
        _erasing data: Binding<Data>
    ) where Value == _AnyMutableRandomAccessCollection<Data.Element> {
        let typeErasedData = _SwiftUIX_ReferenceBox(wrappedValue: _AnyMutableRandomAccessCollection(data.wrappedValue))
        
        self.init(
            get: {
                typeErasedData.wrappedValue
            },
            set: { newValue in
                typeErasedData.wrappedValue = .init(newValue)
                
                data.wrappedValue = newValue.base as! Data
            }
        )
    }
    
    public init<Data: MutableCollection & RandomAccessCollection, TransformedElement>(
        _erasing data: Binding<Data>,
        transform: @escaping (Data.Element) -> TransformedElement,
        backTransform: @escaping (TransformedElement) -> Data.Element
    ) where Value == _AnyMutableRandomAccessCollection<TransformedElement> {
        let transformedData: _SwiftUIX_ReferenceBox<_LazyBidirectionalMapMutableRandomAccessCollection<Data, TransformedElement>> = .init(
            value: _LazyBidirectionalMapMutableRandomAccessCollection(
                base: data.wrappedValue,
                transform: transform,
                backTransform: backTransform
            )
        )
        
        self.init(
            get: {
                _AnyMutableRandomAccessCollection(transformedData.value)
            },
            set: { (newValue: _AnyMutableRandomAccessCollection<TransformedElement>) in
                transformedData.value = _LazyBidirectionalMapMutableRandomAccessCollection(
                    base: (newValue.base as! _LazyBidirectionalMapMutableRandomAccessCollection<Data, TransformedElement>).base,
                    transform: transform,
                    backTransform: backTransform
                )
                
                data.wrappedValue = transformedData.value.base
            }
        )
    }
}

