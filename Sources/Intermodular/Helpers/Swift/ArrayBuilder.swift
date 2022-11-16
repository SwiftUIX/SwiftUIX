//
// Copyright (c) Vatsal Manot
//

import Swift

@resultBuilder
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

    public static func buildBlock(_ arrays: [Element]...) -> [Element] {
        Array(arrays.joined())
    }

    @inlinable
    public static func buildEither(first component: Element) -> [Element] {
        return [component]
    }

    @inlinable
    public static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    @inlinable
    public static func buildEither(second component: [Element]) -> [Element] {
        return component
    }

    @inlinable
    public static func buildExpression(_ element: Element) -> [Element] {
        [element]
    }

    @inlinable
    public static func buildExpression(_ element: Element?) -> [Element] {
        element.map({ [$0] }) ?? []
    }

    @inlinable
    public static func buildExpression(_ elements: [Element]) -> [Element] {
        elements
    }

    @inlinable
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }

    @inlinable
    public static func buildArray(_ contents: [[Element]]) -> [Element] {
        Array(contents.joined())
    }
}
