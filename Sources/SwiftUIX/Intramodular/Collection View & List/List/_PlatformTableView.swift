//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

final class _PlatformTableView<Configuration: _CocoaListConfigurationType>: NSTableView {
    private let heightUpdatesQueue = DispatchQueue.main._debounce()
    
    func noteHeightOfRowsChanged() {
        heightUpdatesQueue.schedule {
            self.reloadData()
            
            DispatchQueue.main.async {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0
                let entireTableView: IndexSet = .init(0..<self.numberOfRows)
                self.noteHeightOfRows(withIndexesChanged: entireTableView)
                NSAnimationContext.endGrouping()
            }
        }
    }
    
    override func noteHeightOfRows(
        withIndexesChanged indexSet: IndexSet
    ) {
        super.noteHeightOfRows(withIndexesChanged: indexSet)
    }
    
    override func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    override func invalidateIntrinsicContentSize() {
        
    }
}

#endif
