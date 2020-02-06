//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension ScrollView {
    public struct Offset {
        public enum Origin {
            case topLeading
            case bottomTrailing
        }
        
        let containerFrame: CGRect
        let contentSize: CGSize
        let contentOffset: CGPoint
        
        func value(from origin: Origin) -> CGPoint {
            switch origin {
                case .topLeading:
                    return contentOffset
                case .bottomTrailing: do {
                    return .init(
                        x: containerFrame.width - contentOffset.x,
                        y: containerFrame.height - contentOffset.y
                    )
                }
            }
        }
        
        func relativeValue(from origin: Origin) -> CGPoint {
            return .init(
                x: value(from: origin).x / (contentSize.width - containerFrame.width),
                y: value(from: origin).y / (contentSize.height - containerFrame.height)
            )
        }
    }
}
