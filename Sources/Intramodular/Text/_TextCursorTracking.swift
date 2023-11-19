//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public final class _TextCursorTracking: ObservableObject {
    private weak var owner: (any _PlatformTextView_Type)?
    
    @Published public private(set) var positionInText: Int?
    @_spi(Internal)
    @Published public private(set) var location: _CoordinateSpaceRelative<CGRect>?

    /// Whether the cursor is at the start of the text.
    public var isAtStart: Bool {
        positionInText == 0
    }
    
    /// Whether the cursor is at the very end of the text.
    public var isAtEnd: Bool {
        guard let owner else {
            return false
        }
        
        return positionInText == owner._SwiftUIX_attributedText.length
    }

    /// Whether the cursor is on the first line.
    ///
    /// Returns `true` even if only one line is displayed.
    public var isOnFirstLine: Bool {
        guard let owner, let positionInText else {
            return false
        }
        
        return owner._lineIndexForCharacterAt(positionInText) == 0
    }
    
    /// Whether the cursor is on the last line.
    ///
    /// Returns `false` if only one line is displayed.
    public var isOnLastLine: Bool {
        guard let owner, let positionInText, let numberOfHardLineBreaks = owner._numberOfHardLineBreaks else {
            return false
        }
        
        return owner._lineIndexForCharacterAt(positionInText) == numberOfHardLineBreaks
    }
    
    init(owner: (any _PlatformTextView_Type)?) {
        self.owner = owner
        
        subscribeToOwner()
        update()
    }
    
    /// Update the tracking state by copying from the owner.
    @_spi(Internal)
    public func update() {
        guard let owner else {
            return
        }
                        
        owner._performOrSchedulePublishingChanges {
            self.positionInText = owner._caretTextPosition
            self.location = owner._SwiftUIX_caretLocation
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension _TextCursorTracking {
    private func subscribeToOwner() {
        
    }
}
#elseif os(macOS)
extension _TextCursorTracking {
    private func subscribeToOwner() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectionDidChange(_:)),
            name: NSTextView.didChangeSelectionNotification,
            object: nil
        )
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        guard let owner, (notification.object as? NSTextView) === owner else {
            return
        }
        
        update()
    }
}
#endif

// MARK: - Auxiliary

extension AppKitOrUIKitTextView {
    var _caretTextPosition: Int? {
        guard let selectedTextRange = _SwiftUIX_selectedTextRange else {
            return nil
        }
        
        return selectedTextRange.length > 0 ? nil : selectedTextRange.location
    }
    
    /// The index of the visible line that the character at the given index is on.
    func _lineIndexForCharacterAt(
        _ location: Int
    ) -> Int? {
        guard let layoutManager = _SwiftUIX_layoutManager, let textStorage = _SwiftUIX_textStorage, location >= 0 && location <= textStorage.length else {
            return nil
        }

        let glyphIndex = layoutManager.glyphIndexForCharacter(at: location)
        var lineRange: NSRange = NSRange()
        layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange)
        
        var lineNumber = 1
        var index = 0
        
        while index < glyphIndex {
            if layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange).origin.y <
                layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil).origin.y {
                lineNumber += 1
            }
            
            index = NSMaxRange(lineRange)
        }
        
        if location == textStorage.length, textStorage.string.last == "\n" {
            lineNumber += 1
        }
        
        return lineNumber - 1
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    var _SwiftUIX_caretLocation: _CoordinateSpaceRelative<CGRect>? {
        guard let selectedRange = selectedTextRange else {
            return nil
        }

        guard selectedRange.isEmpty else {
            return nil
        }
        
        var result = _CoordinateSpaceRelative<CGRect>()

        result[.coordinateSpace(.global)] = caretRect(for: selectedRange.start)

        return result
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    var _SwiftUIX_caretLocation: _CoordinateSpaceRelative<CGRect>? {
        guard let window else {
            return nil
        }

        let selectedRange = selectedRange()
        
        if selectedRange.length > 0 {
            return nil
        } else {
            var unflippedScreenRect = firstRect(forCharacterRange: selectedRange, actualRange: nil)
                        
            if unflippedScreenRect.width == 0 {
                unflippedScreenRect.size.width = 1
            }

            var result = _CoordinateSpaceRelative<CGRect>()
            
            result[.coordinateSpace(.global)] = window.flipLocal(window.convertFromScreen(unflippedScreenRect))
            result[.cocoa(.main)] = NSScreen.flip(unflippedScreenRect)

            return result
        }
    }
}
#endif

#endif
