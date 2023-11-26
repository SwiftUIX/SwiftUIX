//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct _HitTestViewOverlay: AppKitOrUIKitViewRepresentable {
    class AppKitOrUIKitViewType: AppKitOrUIKitView {
        var hitTest: ((CGPoint) -> Bool)? = nil
                
        #if os(macOS)
        override var acceptsFirstResponder: Bool {
            true
        }
        
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
            true
        }

        override func mouseDown(with event: NSEvent) {
            let eventLocationInWindow = event.locationInWindow
            
            let point = self.convert(eventLocationInWindow, from: nil)
        
            guard self.hitTest?(point) ?? true else {
                return
            }
            
            super.mouseDown(with: event)
        }
        #endif
        
        override func hitTest(_ point: CGPoint, with event: AppKitOrUIKitEvent?) -> AppKitOrUIKitView? {
            (self.hitTest?(point) ?? true) ? super.hitTest(point, with: event) : nil
        }
    }
    
    let hitTest: (CGPoint) -> Bool
    
    init(hitTest: @escaping (CGPoint) -> Bool) {
        self.hitTest = hitTest
    }
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType().then {
            #if os(macOS)
            $0.allowedTouchTypes = [.direct]
            #endif
            $0.hitTest = hitTest
        }
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.hitTest = hitTest
    }
}

// MARK: - API

extension View {
    /// Control hit-testing for the view.
    public func hitTest(_ hitTest: @escaping (CGPoint) -> Bool) -> some View {
        overlay(_HitTestViewOverlay(hitTest: hitTest))
    }
}

#endif
