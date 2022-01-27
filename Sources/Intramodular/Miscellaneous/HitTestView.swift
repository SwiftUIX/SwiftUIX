//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A view for hit testing.
fileprivate struct HitTestView<Content: View>: AppKitOrUIKitViewRepresentable {
    typealias AppKitOrUIKitViewType = HitTestContentView
    
    class HitTestContentView: AppKitOrUIKitHostingView<Content> {
        var hitTest: ((CGPoint) -> Bool)? = nil
        
        override func hitTest(_ point: CGPoint, with event: AppKitOrUIKitEvent?) -> AppKitOrUIKitView? {
            (self.hitTest?(point) ?? true) ? super.hitTest(point, with: event) : nil
        }
    }
    
    let rootView: Content
    let hitTest: (CGPoint) -> Bool
    
    init(rootView: Content, hitTest: @escaping (CGPoint) -> Bool) {
        self.rootView = rootView
        self.hitTest = hitTest
    }
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType(rootView: rootView).then {
            $0.hitTest = hitTest
        }
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.hitTest = hitTest
    }
}

// MARK: - Helpers -

extension View {
    public func hitTest(_ hitTest: @escaping (CGPoint) -> Bool) -> some View {
        HitTestView(rootView: self, hitTest: hitTest)
    }
}

#endif
