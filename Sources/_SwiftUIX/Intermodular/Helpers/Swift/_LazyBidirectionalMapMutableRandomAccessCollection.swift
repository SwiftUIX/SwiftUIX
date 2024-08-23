//
// Copyright (c) Vatsal Manot
//

import Swift

@_documentation(visibility: internal)
public struct _LazyBidirectionalMapMutableRandomAccessCollection<C: MutableCollection & RandomAccessCollection, T>: MutableCollection, RandomAccessCollection {
    public typealias Index = C.Index
    public typealias Element = T
    
    public var base: C
    
    private let transform: (C.Element) -> T
    private let backTransform: (T) -> C.Element
    
    public init(
        base: C,
        transform: @escaping (C.Element) -> T,
        backTransform: @escaping (T) -> C.Element
    ) {
        self.base = base
        self.transform = transform
        self.backTransform = backTransform
    }
    
    public var startIndex: Index {
        return base.startIndex
    }
    
    public var endIndex: Index {
        return base.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return base.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return base.index(before: i)
    }
    
    public subscript(position: Index) -> T {
        get {
            return transform(base[position])
        } set {
            base[position] = backTransform(newValue)
        }
    }
}

// MARK: - Supplementary

extension Collection where Self: MutableCollection & RandomAccessCollection {
    public func _map<T>(
        _ transform: @escaping (Element) -> T,
        backTransform: @escaping (T) -> Element
    ) -> _LazyBidirectionalMapMutableRandomAccessCollection<Self, T> {
        return .init(
            base: self,
            transform: transform,
            backTransform: backTransform
        )
    }
}
