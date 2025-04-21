//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import CoreGraphics
import SwiftUI

extension AppKitOrUIKitTextView {
    static func _SwiftUIX_initialize(
        customTextStorage textStorage: NSTextStorage?
    ) -> AppKitOrUIKitTextView {
        let result: Self
        
        if let textStorage: NSTextStorage = textStorage {
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: .zero)

            textStorage.addLayoutManager(layoutManager)
            layoutManager.addTextContainer(textContainer)
            
            result = self.init(frame: .zero, textContainer: textContainer) as! Self
        } else {
            assertionFailure()
            
            result = self.init() as! Self
        }
        
        return result
    }
}

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
    
    public var _SwiftUIX_defaultParagraphStyle: NSParagraphStyle? {
        NSParagraphStyle.default
    }
}

extension AppKitOrUIKitTextView {
    @objc public convenience init(
        _SwiftUIX_usingTextLayoutManager usingTextLayoutManager: Bool
    ) {
        if #available(iOS 16.0, tvOS 16.0, *) {
            if Self.responds(to: #selector(UITextView.init(usingTextLayoutManager:))) {
                self.init(usingTextLayoutManager: usingTextLayoutManager)
                
                return
            }
        }
        
        if #available(iOS 15.0, tvOS 15.0, *) {
            if usingTextLayoutManager {
                let textContainer = NSTextContainer(size: CGSize(width: 0.0, height: 1.0e7))
                let textContentManager = NSTextContentStorage()
                let textLayoutManager = NSTextLayoutManager()
                
                textLayoutManager.textContainer = textContainer
                textContentManager.addTextLayoutManager(textLayoutManager)
                
                self.init(frame: .zero, textContainer: textContainer)
            } else {
                let textStorage = NSTextStorage()
                let layoutManager = NSLayoutManager()
                let textContainer = NSTextContainer()
                
                textStorage.addLayoutManager(layoutManager)
                layoutManager.addTextContainer(textContainer)
                
                self.init(frame: .zero, textContainer: textContainer)
            }
        } else {
            assertionFailure()
            
            self.init(frame: .zero)
        }
    }
}

extension AppKitOrUIKitTextView {
    public var _SwiftUIX_naiveSelectedTextRange: NSRange? {
        get {
            if selectedTextRange != nil {
                return selectedRange
            } else {
                return nil
            }
        } set {
            if let newValue {
                selectedRange = newValue
            } else {
                self.selectedRange = NSRange(location: 0, length: 0)
            }
        }
    }
    
    public var _SwiftUIX_text: String {
        text ?? ""
    }
    
    public var _SwiftUIX_attributedText: NSAttributedString {
        attributedText ?? NSAttributedString()
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
    
    public var _SwiftUIX_defaultParagraphStyle: NSParagraphStyle? {
        defaultParagraphStyle
    }
}

extension AppKitOrUIKitTextView {
    @objc public convenience init(
        _SwiftUIX_usingTextLayoutManager usingTextLayoutManager: Bool
    ) {
        self.init(usingTextLayoutManager: usingTextLayoutManager)
    }
}

extension AppKitOrUIKitTextView {
    public var _SwiftUIX_naiveSelectedTextRange: NSRange? {
        get {
            guard let range = selectedRanges.first as? NSRange else {
                return nil
            }
            
            return range
        } set {
            if let newValue {
                setSelectedRange(newValue)
            } else {
                setSelectedRange(NSRange(location: string.count, length: 0))
            }
        }
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
        let lineSpacing = _SwiftUIX_paragraphStyleOfLastLine?.lineSpacing ?? 0
        
        if let layoutManager = _SwiftUIX_layoutManager {
            lineHeight = max(lineHeight, layoutManager.defaultLineHeight(for: font))
        }
        
        return lineHeight + lineSpacing
    }
    
    public var _SwiftUIX_paragraphStyleOfLastLine: NSParagraphStyle? {
        guard let textStorage = _SwiftUIX_textStorage else {
            return _SwiftUIX_defaultParagraphStyle
        }
        
        if textStorage.length == 0 {
            return _SwiftUIX_defaultParagraphStyle
        }
        
        guard let selectedRange = _SwiftUIX_naiveSelectedTextRange else {
            return _SwiftUIX_defaultParagraphStyle
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
            return _SwiftUIX_defaultParagraphStyle
        }
        
        let paragraphStyle = textStorage.attributes(at: location, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle
        
        guard let paragraphStyle else {
            return _SwiftUIX_defaultParagraphStyle
        }
        
        return paragraphStyle
    }
}

extension AppKitOrUIKitTextView {
    public func invalidateGlyphs(
        for range: NSRange,
        changeInLength: Int
    ) {
        guard let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
            assertionFailure()
            
            return
        }
        
        layoutManager.invalidateGlyphs(
            forCharacterRange: range,
            changeInLength: changeInLength,
            actualCharacterRange: nil
        )
    }

    public func invalidateLayout(
        for range: NSRange
    ) {
        guard let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
            assertionFailure()

            return
        }
        
        layoutManager.invalidateLayout(
            forCharacterRange: range,
            actualCharacterRange: nil
        )
    }
    
    public func invalidateDisplay(
        for range: NSRange
    ) {
        guard let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
            assertionFailure()

            return
        }
        
        layoutManager.invalidateDisplay(
            forCharacterRange: range
        )
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
    public var horizontal: CGFloat {
        width
    }
    
    public var vertical: CGFloat {
        height
    }
}
#endif

#endif
