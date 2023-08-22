//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    public var _SwiftUIX_layoutManager: NSLayoutManager? {
        layoutManager
    }
    
    public var _SwiftUIX_selectedRange: NSRange {
        selectedRange
    }
    
    public var _SwiftUIX_textStorage: NSTextStorage? {
        textStorage
    }
    
    var defaultParagraphStyle: NSParagraphStyle? {
        NSParagraphStyle.default
    }
    
    func _sizeThatFits(
        forWidth width: CGFloat
    ) -> CGSize? {
        let storage = NSTextStorage(attributedString: attributedText)
        let width = bounds.width - textContainerInset.horizontal
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        let manager = NSLayoutManager()
        
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)
        
        container.lineFragmentPadding = textContainer.lineFragmentPadding
        container.lineBreakMode = textContainer.lineBreakMode
        
        _ = manager.glyphRange(for: container)
        
        let usedRect = manager.usedRect(for: container)
        
        return CGSize(
            width: ceil(usedRect.size.width + textContainerInset.horizontal),
            height: ceil(usedRect.size.height + textContainerInset.vertical)
        )
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    public var _SwiftUIX_layoutManager: NSLayoutManager? {
        layoutManager
    }
    
    public var _SwiftUIX_selectedRange: NSRange {
        selectedRange()
    }
    
    public var _SwiftUIX_textStorage: NSTextStorage? {
        textStorage
    }
    
    func _sizeThatFits(
        forWidth width: CGFloat
    ) -> CGSize? {
        guard let layoutManager, let textContainer else {
            return nil
        }
        
        let originalWidth = frame.size.width
        
        frame.size.width = width
        
        textContainer.containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.invalidateLayout(forCharacterRange: NSRange(location: 0, length: 0), actualCharacterRange: nil)
        
        layoutManager.glyphRange(for: textContainer)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        frame.size.width = originalWidth
        
        return usedRect.size
    }
}
#endif

extension AppKitOrUIKitTextView {
    var _numberOfLinesDisplayed: Int {
        guard let layoutManager = _SwiftUIX_layoutManager else {
            return 0
        }
        
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var index = 0
        var numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            
            index = NSMaxRange(lineRange)
            
            numberOfLines += 1
        }
        
        return numberOfLines
    }
    
    var _lastLineParagraphStyle: NSParagraphStyle? {
        guard let textStorage = _SwiftUIX_textStorage else {
            return defaultParagraphStyle
        }
        
        if textStorage.length == 0 {
            return defaultParagraphStyle
        }
        
        let selectedRange = _SwiftUIX_selectedRange
        
        let location: Int
        
        if selectedRange.location == NSNotFound {
            location = max(0, textStorage.length - 1)
        } else if selectedRange.location == textStorage.length {
            location = 0
        } else {
            location = selectedRange.location
        }
        
        guard location < textStorage.length else {
            return defaultParagraphStyle
        }
        
        let paragraphStyle = textStorage.attributes(at: location, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle
        
        guard let paragraphStyle else {
            return defaultParagraphStyle
        }
        
        return paragraphStyle
    }
    
    var _heightDifferenceForNewline: CGFloat? {
        guard let font = font else {
            return nil
        }
        
        var lineHeight = font.ascender + font.descender + font.leading
        let lineSpacing = _lastLineParagraphStyle?.lineSpacing ?? 0
        
        if let layoutManager = _SwiftUIX_layoutManager {
            lineHeight = max(lineHeight, layoutManager.defaultLineHeight(for: font))
        }
        
        return lineHeight + lineSpacing
    }
}

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension NSLayoutManager {
    public func defaultLineHeight(for font: UIFont) -> CGFloat {
        let paragraphStyle = NSParagraphStyle.default
        
        return font.lineHeight * paragraphStyle.lineHeightMultiple + paragraphStyle.lineSpacing
    }
}
#endif

#endif
