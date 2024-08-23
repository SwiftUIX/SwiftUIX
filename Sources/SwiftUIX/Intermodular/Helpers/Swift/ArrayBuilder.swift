//
// Copyright (c) Vatsal Manot
//

import Swift

#if compiler(<5.8)
@available(*, deprecated, renamed: "_ArrayBuilder")
public typealias ArrayBuilder = _ArrayBuilder
#endif

@resultBuilder
@_documentation(visibility: internal)
public struct _ArrayBuilder<Element> {
    @_optimize(speed)
    @_transparent
    public static func buildBlock() -> [Element] {
        return []
    }

    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ element: Element) -> [Element] {
        return [element]
    }

    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ elements: Element...) -> [Element] {
        return elements
    }
    
    @_optimize(speed)
    @_transparent
    public static func buildBlock(_ arrays: [Element]...) -> [Element] {
        arrays.flatMap({ $0 })
    }

    @_optimize(speed)
    @_transparent
    public static func buildEither(first component: Element) -> [Element] {
        return [component]
    }

    @_optimize(speed)
    @_transparent
    public static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    @_optimize(speed)
    @_transparent
    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }

    @_optimize(speed)
    @_transparent
    public static func buildExpression(_ element: Element) -> [Element] {
        [element]
    }

    @_optimize(speed)
    @_transparent
    public static func buildExpression(_ element: Element?) -> [Element] {
        element.map({ [$0] }) ?? []
    }

    @_optimize(speed)
    @_transparent
    public static func buildExpression(_ elements: [Element]) -> [Element] {
        elements
    }

    @_optimize(speed)
    @_transparent
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }

    @_optimize(speed)
    @_transparent
    public static func buildArray(_ contents: [[Element]]) -> [Element] {
        contents.flatMap({ $0 })
    }
}
