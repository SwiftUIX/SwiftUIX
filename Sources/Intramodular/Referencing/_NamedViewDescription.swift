//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view description.
///
/// The description is composed of two things - the view's name and the view's frame.
public struct _NamedViewDescription: Hashable {
    @usableFromInline
    let name: ViewName
    @usableFromInline
    let bounds: Anchor<CGRect>
    @usableFromInline
    let globalBounds: CGRect
    
    @usableFromInline
    init(
        name: ViewName,
        bounds: Anchor<CGRect>,
        globalBounds: CGRect
    ) {
        self.name = name
        self.bounds = bounds
        self.globalBounds = globalBounds
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(globalBounds.origin.x)
        hasher.combine(globalBounds.origin.y)
        hasher.combine(globalBounds.size.width)
        hasher.combine(globalBounds.size.height)
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        
        guard lhs.globalBounds == rhs.globalBounds else {
            return false
        }
        
        return true
    }
}

extension _NamedViewDescription {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        struct Value: Equatable, Sequence {
            typealias Element = _NamedViewDescription
            
            var allAsArray: [Element]
            var allAsDictionary: [ViewName: Element]
            
            var first: Element? {
                allAsArray.first
            }
            
            var last: Element? {
                allAsArray.last
            }
            
            init(_ element: Element) {
                self.allAsArray = [element]
                self.allAsDictionary = [element.name: element]
            }
            
            init() {
                self.allAsArray = []
                self.allAsDictionary = [:]
            }
            
            func makeIterator() -> AnyIterator<Element> {
                .init(allAsArray.makeIterator())
            }
        }
        
        static var defaultValue: Value {
            Value()
        }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            let nextValue = nextValue()
            
            value.allAsArray.append(contentsOf: nextValue.allAsArray)
            value.allAsDictionary.merge(nextValue.allAsDictionary, uniquingKeysWith: { lhs, rhs in lhs })
        }
    }
}
