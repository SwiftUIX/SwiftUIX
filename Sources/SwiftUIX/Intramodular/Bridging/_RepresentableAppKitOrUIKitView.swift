//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct _SwiftUIX_ProposedSize: Hashable {
    let width: CGFloat?
    let height: CGFloat?

    init(_ proposedSize: SwiftUI._ProposedSize) {
        self.width = proposedSize.width
        self.height = proposedSize.height
    }
 
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    init(_ proposedSize: SwiftUI.ProposedViewSize) {
        self.width = proposedSize.width
        self.height = proposedSize.height
    }
}

extension OptionalDimensions {
    init(_ proposedSize: _SwiftUIX_ProposedSize) {
        self.init(width: proposedSize.width, height: proposedSize.height)
    }
}

extension SwiftUI._ProposedSize {
    fileprivate var width: CGFloat? {
        Mirror(reflecting: self).children.lazy.compactMap { label, value in
            label == "width" ? value as? CGFloat : nil
        }.first
    }

    fileprivate var height: CGFloat? {
        Mirror(reflecting: self).children.lazy.compactMap { label, value in
            label == "height" ? value as? CGFloat : nil
        }.first
    }
}
