//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSView {
    public struct AnimationOptions: OptionSet {
        public static let curveEaseInOut = AnimationOptions(rawValue: 1 << 0)
        public static let curveEaseIn = AnimationOptions(rawValue: 1 << 1)
        public static let curveEaseOut = AnimationOptions(rawValue: 1 << 2)
        public static let curveLinear = AnimationOptions(rawValue: 1 << 3)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public func _toCAAnimationMediaTimingFunction() -> CAMediaTimingFunctionName {
            switch self {
                case .curveEaseIn:
                    return CAMediaTimingFunctionName.easeIn
                case .curveEaseOut:
                    return CAMediaTimingFunctionName.easeOut
                case .curveLinear:
                    return CAMediaTimingFunctionName.linear
                default:
                    return CAMediaTimingFunctionName.default
            }
        }
    }
    
    public static func animate(
        withDuration duration: TimeInterval,
        delay: TimeInterval = 0.0,
        options: AnimationOptions = .curveEaseInOut,
        @_implicitSelfCapture animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: options._toCAAnimationMediaTimingFunction())
            
            if delay > 0.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    animations()
                }
            } else {
                animations()
            }
            
        } completionHandler: {
            completion?(true)
        }
    }
}

#endif
