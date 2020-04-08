//
// Copyright (c) Vatsal Manot
//

import Swift

@_functionBuilder
public class ArrayBuilder<Element> {
    @inlinable
    public static func buildBlock() -> [Element] {
        return []
    }
    
    @inlinable
    public static func buildBlock(_ element: Element) -> [Element] {
        return [element]
    }
    
    @inlinable
    public static func buildBlock(_ elements: Element...) -> [Element] {
        return elements
    }
}
