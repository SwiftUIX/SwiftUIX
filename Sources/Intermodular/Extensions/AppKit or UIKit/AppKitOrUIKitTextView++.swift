//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    public var _SwiftUIX_textContainer: NSTextContainer? {
        textContainer
    }
    
    public var _SwiftUIX_layoutManager: NSLayoutManager? {
        layoutManager
    }
    
    public var _SwiftUIX_textStorage: NSTextStorage? {
        textStorage
    }
}

extension AppKitOrUIKitTextView {
    public var _SwiftUIX_selectedTextRange: NSRange? {
        selectedRange
    }
        
    public var _SwiftUIX_text: String {
        text ?? ""
    }

    public var _SwiftUIX_attributedText: NSAttributedString {
        attributedText ?? NSAttributedString()
    }

    var defaultParagraphStyle: NSParagraphStyle? {
        NSParagraphStyle.default
    }
        
    func adjustFontSizeToFitWidth() {
        guard !text.isEmpty && !bounds.size.equalTo(CGSize.zero) else {
            return
        }
        
        let textViewSize = frame.size
        let fixedWidth = textViewSize.width;
        let expectSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if expectSize.height > textViewSize.height {
            while sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height > textViewSize.height {
                font = font!.withSize(font!.pointSize - 1)
            }
        } else {
            while sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height < textViewSize.height {
                font = font!.withSize(font!.pointSize + 1)
            }
        }
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    public var _SwiftUIX_textContainer: NSTextContainer? {
        textContainer
    }
    
    public var _SwiftUIX_layoutManager: NSLayoutManager? {
        layoutManager
    }
        
    public var _SwiftUIX_textStorage: NSTextStorage? {
        textStorage
    }
}

extension AppKitOrUIKitTextView {
    public var _SwiftUIX_selectedTextRange: NSRange? {
        selectedRanges.first as? NSRange
    }
            
    public var _SwiftUIX_text: String {
        string
    }

    public var _SwiftUIX_attributedText: NSAttributedString {
        attributedString()
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
        
        guard let selectedRange = _SwiftUIX_selectedTextRange else {
            return defaultParagraphStyle
        }
        
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
        
    func _sizeThatFits(
        width: CGFloat,
        accountForNewline: Bool = false
    ) -> CGSize? {
        _sizeThatFitsWithoutCopying(
            width: width,
            accountForNewline: accountForNewline
        )
    }
    
    private func _sizeThatFitsWithoutCopying(
        width: CGFloat,
        accountForNewline: Bool
    ) -> CGSize? {
        guard  let textContainer = _SwiftUIX_textContainer, let layoutManager = _SwiftUIX_layoutManager, let textStorage = _SwiftUIX_textStorage else {
            return nil
        }
                
        let originalTextContainerSize = textContainer.containerSize
      
        textContainer.containerSize = CGSize(width: width, height: 10000000.0)
        
        defer {
            textContainer.size = originalTextContainerSize
        }
        
        layoutManager.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)
        
        /*if let view = self as? (any _PlatformTextView_Type), view.representableCache._sizeThatFitsCache.isEmpty {
            _ = layoutManager.glyphRange(for: textContainer)
        }*/

        layoutManager.ensureLayout(for: textContainer)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        if usedRect.isEmpty {
            if (!width.isNormal && !textStorage.string.isEmpty) {
                return nil
            }
            
            guard textStorage.string.isEmpty else {
                let originalSize = frame.size
            
                frame.size.width = width
                
                defer {
                    frame.size.width = originalSize.width
                }

                layoutManager.ensureLayout(for: textContainer)
                
                let usedRect2 = layoutManager.usedRect(for: textContainer)
                
                guard !usedRect2.isEmpty else {
                    return nil
                }
                
                return usedRect2.size
            }
        }

        return usedRect.size
    }
    
    private func _sizeThatFitsByCopying(
        width: CGFloat,
        accountForNewline: Bool
    ) -> CGSize? {
        guard let textContainer = _SwiftUIX_textContainer, let textStorage = _SwiftUIX_textStorage else {
            return nil
        }
        
        let temporaryTextStorage = NSTextStorage(attributedString: textStorage)
        let width = bounds.width - textContainerInset.horizontal
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let temporaryTextContainer = NSTextContainer(size: containerSize)
        let temporaryLayoutManager = NSLayoutManager()
        
        temporaryLayoutManager.addTextContainer(temporaryTextContainer)
        temporaryTextStorage.addLayoutManager(temporaryLayoutManager)
        
        temporaryTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        temporaryTextContainer.lineBreakMode = textContainer.lineBreakMode
        
        _ = temporaryLayoutManager.glyphRange(for: temporaryTextContainer)
        
        let usedRect = temporaryLayoutManager.usedRect(for: temporaryTextContainer)
        
        var result = CGSize(
            width: ceil(usedRect.size.width + textContainerInset.horizontal),
            height: ceil(usedRect.size.height + textContainerInset.vertical)
        )
        
        if accountForNewline {
            if temporaryTextStorage.string.hasSuffix("\n") {
                result.height += (_heightDifferenceForNewline ?? 0)
            }
        }
        
        return result
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
#elseif os(macOS)
extension NSSize {
    fileprivate var horizontal: CGFloat {
        width
    }
    
    fileprivate var vertical: CGFloat {
        height
    }
}
#endif

#endif
