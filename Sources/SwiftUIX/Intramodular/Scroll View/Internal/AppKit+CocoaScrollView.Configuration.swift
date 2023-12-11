//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)
extension NSScrollView {
    func configure<Content: View>(
        with configuration: CocoaScrollViewConfiguration<Content>
    ) {
        if let showsVerticalScrollIndicator = configuration.showsVerticalScrollIndicator {
            self.hasVerticalScroller = showsVerticalScrollIndicator
        }
        
        if let showsHorizontalScrollIndicator = configuration.showsHorizontalScrollIndicator {
            self.hasHorizontalScroller = showsHorizontalScrollIndicator
        }
    }
}
#endif
