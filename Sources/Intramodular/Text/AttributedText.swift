//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct AttributedText: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitLabel
    
    struct Configuration: Hashable {
        var appKitOrUIKitFont: AppKitOrUIKitFont?
        var appKitOrUIKitForegroundColor: AppKitOrUIKitColor?
    }
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.adjustsFontSizeToFitWidth) var adjustsFontSizeToFitWidth
    @Environment(\.allowsTightening) var allowsTightening
    @Environment(\.font) var font
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.lineBreakMode) var lineBreakMode
    @Environment(\.lineLimit) var lineLimit
    @Environment(\.minimumScaleFactor) var minimumScaleFactor
    @Environment(\.preferredMaximumLayoutWidth) var preferredMaximumLayoutWidth
    #if os(macOS)
    @Environment(\.layoutDirection) var layoutDirection
    #endif
    
    public let content: NSAttributedString
    
    var configuration = Configuration()
    
    public init(_ content: NSAttributedString) {
        self.content = content
    }
    
    public init<S: StringProtocol>(_ content: S) {
        self.init(NSAttributedString(string: String(content)))
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType()
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.configure(with: self)
    }
}

// MARK: - API -

extension AttributedText {
    public func font(_ font: AppKitOrUIKitFont) -> Self {
        then({ $0.configuration.appKitOrUIKitFont = font })
    }
    
    public func foregroundColor(_ foregroundColor: AppKitOrUIKitColor) -> Self {
        then({ $0.configuration.appKitOrUIKitForegroundColor = foregroundColor })
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @_disfavoredOverload
    public func foregroundColor(_ foregroundColor: Color) -> Self {
        then({ $0.configuration.appKitOrUIKitForegroundColor = foregroundColor.toUIColor() })
    }
    #endif
}

// MARK: - Auxiliary Implementation -

extension AppKitOrUIKitLabel {
    func configure(with attributedText: AttributedText) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        self.allowsDefaultTighteningForTruncation = attributedText.allowsTightening
        #endif
        self.font = attributedText.configuration.appKitOrUIKitFont ?? self.font
        self.adjustsFontSizeToFitWidth = attributedText.adjustsFontSizeToFitWidth
        self.lineBreakMode = attributedText.lineBreakMode
        self.minimumScaleFactor = attributedText.minimumScaleFactor
        self.numberOfLines = attributedText.lineLimit ?? 0
        self.textColor = attributedText.configuration.appKitOrUIKitForegroundColor ?? self.textColor
        
        #if os(macOS)
        self.setAccessibilityEnabled(attributedText.accessibilityEnabled)
        self.userInterfaceLayoutDirection = .init(attributedText.layoutDirection)
        #endif
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let font = attributedText.configuration.appKitOrUIKitFont ?? attributedText.font?.toUIFont() {
            let string = NSMutableAttributedString(attributedString: attributedText.content)
            
            string.addAttribute(.font, value: font, range: .init(location: 0, length: string.length))
            
            self.attributedText = attributedText.content
        } else {
            self.attributedText = attributedText.content
        }
        #else
        self.attributedText = attributedText.content
        #endif
        
        if let preferredMaximumLayoutWidth = attributedText.preferredMaximumLayoutWidth, preferredMaxLayoutWidth != attributedText.preferredMaximumLayoutWidth {
            preferredMaxLayoutWidth = preferredMaximumLayoutWidth
            
            frame.size.width = min(frame.size.width, preferredMaximumLayoutWidth)
            
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            setNeedsLayout()
            layoutIfNeeded()
            #endif
        }
        
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}

#endif
