//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct AttributedText: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitLabel
    
    public let content: NSAttributedString
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.lineLimit) var lineLimit
    @Environment(\.minimumScaleFactor) var minimumScaleFactor

    #if os(macOS)
    @Environment(\.layoutDirection) var layoutDirection
    #endif
    
    public init(_ content: NSAttributedString) {
        self.content = content
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType().then {
            $0.attributedText = content
        }
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.attributedText = content
        view.minimumScaleFactor = minimumScaleFactor
        view.numberOfLines = lineLimit ?? 0
            
        #if os(macOS)
        view.setAccessibilityEnabled(accessibilityEnabled)
        view.userInterfaceLayoutDirection = .init(layoutDirection)
        #endif
    }
}

#endif
