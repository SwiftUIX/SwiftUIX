//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS)

/// A view for hit testing.
fileprivate struct HitTestView<Content: View>: UIViewRepresentable {
    typealias Context = UIViewRepresentableContext<Self>
    typealias UIViewType = HitTestContentView
    
    class HitTestContentView: UIHostingView<Content> {
        let hitTest: (CGPoint) -> Bool
        
        init(rootView: Content, hitTest: @escaping (CGPoint) -> Bool) {
            self.hitTest = hitTest
            
            super.init(rootView: rootView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            self.hitTest(point) ? super.hitTest(point, with: event) : nil
        }
    }
    
    let rootView: Content
    let hitTest: (CGPoint) -> Bool
    
    init(rootView: Content, hitTest: @escaping (CGPoint) -> Bool) {
        self.rootView = rootView
        self.hitTest = hitTest
    }
    
    func makeUIView(context: Context) -> UIViewType {
        return .init(rootView: rootView, hitTest: hitTest)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

// MARK: - Helpers -

extension View {
    public func hitTest(_ hitTest: @escaping (CGPoint) -> Bool) -> some View {
        return HitTestView(rootView: self, hitTest: hitTest)
    }
}

#endif
