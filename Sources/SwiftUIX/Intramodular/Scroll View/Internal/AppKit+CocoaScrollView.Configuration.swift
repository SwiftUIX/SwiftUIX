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
            _assignIfNotEqual(showsVerticalScrollIndicator, to: \.hasVerticalScroller)
        }
        
        if let showsHorizontalScrollIndicator = configuration.showsHorizontalScrollIndicator {
            _assignIfNotEqual(showsHorizontalScrollIndicator, to: \.hasHorizontalScroller)
        }
    }
}
#endif
