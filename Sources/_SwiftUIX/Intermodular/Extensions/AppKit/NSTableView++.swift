//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@_spi(Internal)
extension NSTableView {
    public func visibleTableViewCellViews() -> [NSTableCellView] {
        var cellViews: [NSTableCellView] = []
        
        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                if let cellView = view(atColumn: column, row: row, makeIfNecessary: false) as? NSTableCellView {
                    cellViews.append(cellView)
                }
            }
        }
        
        return cellViews
    }
}

#endif
