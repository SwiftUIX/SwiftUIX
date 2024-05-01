//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
    
    public func insertText(
        _ insertString: Any,
        replacementRange: NSRange
    ) {
        guard let text = (insertString as? String) else {
            assertionFailure("Unsupported type: \(type(of: insertString))")
            
            return
        }
        
        let startPosition: UITextPosition
        
        if let range = selectedTextRange {
            startPosition = range.start
        } else {
            startPosition = beginningOfDocument
        }
        
        let startIndex = self.offset(from: beginningOfDocument, to: startPosition)
        
        let replaceStartIndex = startIndex + replacementRange.location
        let replaceEndIndex = replaceStartIndex + replacementRange.length
        
        if
            let replaceStartPosition: UITextPosition = self.position(from: beginningOfDocument, offset: replaceStartIndex),
            let replaceEndPosition: UITextPosition = self.position(from: beginningOfDocument, offset: replaceEndIndex),
            let textRange = self.textRange(from: replaceStartPosition, to: replaceEndPosition)
        {
            replace(textRange, withText: text)
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
        guard let range = selectedRanges.first as? NSRange else {
            return nil
        }
        
        return range
    }
    
    public var _SwiftUIX_text: String {
        string
    }
    
    public var _SwiftUIX_attributedText: NSAttributedString {
        get {
            attributedString()
        } set {
            _SwiftUIX_textStorage?.setAttributedString(newValue)
        }
    }
}
#endif

extension AppKitOrUIKitTextView {
    var _numberOfHardLineBreaks: Int? {
        let string = self._SwiftUIX_text
        
        guard !string.isEmpty else {
            return nil
        }
        
        var numberOfLines = 0
        var index = string.startIndex
        
        while index < string.endIndex {
            let lineRange = string.lineRange(for: index..<index)
            numberOfLines += 1
            index = lineRange.upperBound
        }
        
        return numberOfLines
    }
    
    var _numberOfLinesOfWrappedTextDisplayed: Int {
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
    
    func _sizeThatFits(
        width: CGFloat
    ) -> CGSize? {
        _sizeThatFitsWithoutCopying(width: width)
    }
    
    private func _sizeThatFitsWithoutCopying(
        width: CGFloat
    ) -> CGSize? {
        guard let textContainer = _SwiftUIX_textContainer, let layoutManager = _SwiftUIX_layoutManager, let textStorage = _SwiftUIX_textStorage else {
            return nil
        }
        
        let originalSize = frame.size
        let originalTextContainerSize = textContainer.containerSize
        
        guard width.isNormal && width != .greatestFiniteMagnitude else {
            return nil
        }
        
        // frame.size.width = width
        textContainer.containerSize = CGSize(width: width, height: 10000000.0)
        
        defer {
            textContainer.size = originalTextContainerSize
            frame.size.width = originalSize.width
        }
        
        layoutManager.invalidateLayout(
            forCharacterRange: NSRange(location: 0, length: textStorage.length),
            actualCharacterRange: nil
        )
        
        /// Uncommenting out this line without also uncommenting out `frame.size.width = width` will result in placeholder max width being returned.
        // let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        layoutManager.ensureLayout(for: textContainer)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        // let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        if usedRect.isEmpty {
            if (!width.isNormal && !textStorage.string.isEmpty) {
                return nil
            }
            
            guard textStorage.string.isEmpty else {
                frame.size.width = width
                
                defer {
                    frame.size.width = originalSize.width
                }
                
                layoutManager.ensureLayout(for: textContainer)
                
                let usedRect2 = layoutManager.usedRect(for: textContainer)
                
                guard !usedRect2.isEmpty else {
                    return nil
                }
                
                if usedRect2.size._hasPlaceholderDimensions(for: .textContainer) {
                    assertionFailure()
                }
                
                return usedRect2.size
            }
        }
        
        if usedRect.size._hasPlaceholderDimensions(for: .textContainer) {
            assertionFailure()
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

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
