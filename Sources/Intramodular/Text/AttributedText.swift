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
    @Environment(\.allowsTightening) var allowsTightening
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.lineLimit) var lineLimit
    @Environment(\.minimumScaleFactor) var minimumScaleFactor
    
    #if os(macOS)
    @Environment(\.layoutDirection) var layoutDirection
    #endif
    
    public init(_ content: NSAttributedString) {
        self.content = content
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType().then({ $0.configure(with: self) })
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.configure(with: self)
    }
}

// MARK: - Helpers -

extension AppKitOrUIKitLabel {
    func configure(with attributedText: AttributedText) {
        self.attributedText = attributedText.content
        self.minimumScaleFactor = attributedText.minimumScaleFactor
        self.numberOfLines = attributedText.lineLimit ?? 0
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        self.allowsDefaultTighteningForTruncation = attributedText.allowsTightening
        #endif
        
        #if os(macOS)
        self.setAccessibilityEnabled(attributedText.accessibilityEnabled)
        self.userInterfaceLayoutDirection = .init(attributedText.layoutDirection)
        #endif
    }
}

#endif
