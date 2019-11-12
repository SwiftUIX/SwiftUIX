//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ViewListMaker {
    func makeViewList() -> [AnyView]
}

// MARK: - Concrete Implementations -

extension EmptyView: ViewListMaker {
    public func makeViewList() -> [AnyView] {
        []
    }
}

extension ForEach: ViewListMaker where Content: View {
    public func makeViewList() -> [AnyView] {
        data.map({ self.content($0).eraseToAnyView() })
    }
}

extension TupleView: ViewListMaker {
    public func makeViewList() -> [AnyView] {
        Mirror(reflecting: value).children.compactMap({ $0.value as? AnyView }) // HACK
    }
}
