//
// Copyright (c) Vatsal Manot
//

import Swift

@_functionBuilder
public class ArrayBuilder<Element> {
    public static func buildBlock() -> [Element] {
        return []
    }
    
    public static func buildBlock(_ element: Element) -> [Element] {
        return [element]
    }
    
    public static func buildBlock(_ elements: Element...) -> [Element] {
        return elements
    }
}
