//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _ViewListMaker {
    func makeViewList() -> [AnyView]
}

// MARK: - Conformances

extension EmptyView: _ViewListMaker {
    @inlinable
    public func makeViewList() -> [AnyView] {
        []
    }
}

extension ForEach: _ViewListMaker where Content: View {
    @inlinable
    public func makeViewList() -> [AnyView] {
        data.map({ self.content($0).eraseToAnyView() })
    }
}

extension TupleView: _ViewListMaker {
    @inlinable
    public func makeViewList() -> [AnyView] {
        Mirror(reflecting: value).children.map({ $0.value as! AnyView }) 
    }
}
