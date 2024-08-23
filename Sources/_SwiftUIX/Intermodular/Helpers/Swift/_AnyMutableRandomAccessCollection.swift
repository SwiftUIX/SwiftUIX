//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public struct _AnyMutableRandomAccessCollection<Element>: RandomAccessCollection, MutableCollection {
    public typealias Index = _AnyMutableCollectionIndex
    
    private var box: AnyCollectionBox<Element>
    
    public var base: Any {
        box._base
    }
    
    public init<C: RandomAccessCollection & MutableCollection>(
        _ collection: C
    ) where C.Element == Element {
        box = MutableRandomAccessCollectionBox(collection)
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
    
    public func index(before i: Index) -> Index {
        box.index(before: i)
    }
    
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        box.index(i, offsetBy: distance)
    }
    
    public func distance(from start: Index, to end: Index) -> Int {
        box.distance(from: start, to: end)
    }
    
    public subscript(
        position: Index
    ) -> Element {
        get {
            box.getElement(at: position)
        } set {
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

// MARK: - Internal

// Base class for type erasure that operates on elements of type Element
private class AnyCollectionBox<Element>: NSCopying {
    typealias Index = _AnyMutableCollectionIndex
    
    var _base: Any {
        fatalError("Must override")
    }
    
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
    
    func index(before i: Index) -> Index {
        fatalError("Must override")
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        fatalError("Must override")
    }
    
    func distance(from start: Index, to end: Index) -> Int {
        fatalError("Must override")
    }
}

// Concrete subclass of AnyCollectionBox for specific collection types
private final class MutableRandomAccessCollectionBox<Base: RandomAccessCollection & MutableCollection>: AnyCollectionBox<Base.Element>  {
    private var base: Base
    
    override var _base: Any {
        base
    }
    
    init(_ base: Base) {
        self.base = base
    }
    
    override var startIndex: Index {
        Index(base.startIndex)
    }
    
    override var endIndex: Index {
        Index(base.endIndex)
    }
    
    override func index(after i: Index) -> Index {
        guard let concreteIndex = i.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return Index(base.index(after: concreteIndex))
    }
    
    override func index(before i: Index) -> Index {
        guard let concreteIndex = i.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return Index(base.index(before: concreteIndex))
    }
    
    override func index(_ i: Index, offsetBy distance: Int) -> Index {
        guard let concreteIndex = i.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return Index(base.index(concreteIndex, offsetBy: distance))
    }
    
    override func distance(from start: Index, to end: Index) -> Int {
        guard let startConcreteIndex = start.base as? Base.Index, let endConcreteIndex = end.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        return base.distance(from: startConcreteIndex, to: endConcreteIndex)
    }
    
    override func getElement(at index: Index) -> Base.Element {
        guard let concreteIndex = index.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        
        return base[concreteIndex]
    }
    
    override func setElement(_ element: Base.Element, at index: Index) {
        guard let concreteIndex = index.base as? Base.Index else {
            fatalError("Index type mismatch")
        }
        
        base[concreteIndex] = element
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        return MutableRandomAccessCollectionBox(base)
    }
}
