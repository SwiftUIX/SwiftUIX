//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

public struct _AppKitOrUIKitViewAnimation: Equatable  {
    public let options: AppKitOrUIKitView.AnimationOptions?
    public let duration: CGFloat?
    
    init(
        options: AppKitOrUIKitView.AnimationOptions?,
        duration: CGFloat?
    ) {
        self.options = options
        self.duration = duration
    }
    
    public init(
        options: AppKitOrUIKitView.AnimationOptions,
        duration: CGFloat
    ) {
        self.options = options
        self.duration = duration
    }
    
    public static var `default`: Self {
        .init(options: nil, duration: nil)
    }
    
    public static func linear(duration: Double) -> Self {
        .init(options: .curveLinear, duration: duration)
    }
    
    public static var linear: Self {
        .init(options: .curveLinear, duration: 0.3)
    }
    
    public static func easeInOut(duration: Double) -> Self {
        .init(options: .curveEaseInOut, duration: duration)
    }
    
    public static var easeInOut: Self {
        .init(options: .curveEaseInOut, duration: 0.3)
    }
    
    public static func easeIn(duration: Double) -> Self {
        .init(options: .curveEaseIn, duration: duration)
    }
    
    public static var easeIn: Self {
        .init(options: .curveEaseIn, duration: 0.3)
    }
    
    public static func easeOut(duration: Double) -> Self {
        .init(options: .curveEaseOut, duration: duration)
    }
    
    public static var easeOut: Self {
        .init(options: .curveEaseOut, duration: 0.3)
    }
}

#endif
