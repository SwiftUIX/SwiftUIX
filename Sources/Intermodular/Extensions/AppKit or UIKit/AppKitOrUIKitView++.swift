//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

extension AppKitOrUIKitView {
    @usableFromInline
    var isHorizontalContentHuggingPriorityHigh: Bool {
        contentHuggingPriority(for: .horizontal) == .defaultHigh
    }
    
    @usableFromInline
    var isVerticalContentHuggingPriorityHigh: Bool {
        contentHuggingPriority(for: .vertical) == .defaultHigh
    }
    
    func _UIKit_only_sizeToFit() {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        sizeToFit()
        #endif
    }
}

#endif
