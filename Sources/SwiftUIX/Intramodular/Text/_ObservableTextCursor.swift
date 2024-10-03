//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI
@_spi(Internal) import _SwiftUIX

@available(*, deprecated, renamed: "_ObservableTextCursor")
public typealias _TextCursorTracking = _ObservableTextCursor

extension AppKitOrUIKitTextView {
    
}

extension _ObservableTextCursor {
    /// The current text selection.
    public struct TextSelection: Equatable {
        private weak var owner: (any _PlatformTextViewType)?
        
        public let range: NSRange
        public let geometry: _CoordinateSpaceRelative<CGRect>
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.range == rhs.range && lhs.geometry == rhs.geometry
        }
        
        init?(from owner: (any _PlatformTextViewType)) {
            guard let range = owner._SwiftUIX_selectedTextRange else {
                return nil
            }
            
            guard let geometry = owner._SwiftUIX_selectedRangeGeometry else {
                return nil
            }
            
            guard !geometry.size.isAreaZero else {
                // assert(range.length == 0)
                
                return nil
            }
                        
            self.range = range
            self.geometry = geometry
        }
    }
}

@_documentation(visibility: internal)
public final class _ObservableTextCursor: ObservableObject {
    private weak var owner: (any _PlatformTextViewType)?
    
    @Published public private(set) var positionInText: Int?
    @Published public private(set) var location: _CoordinateSpaceRelative<CGRect>?
    @Published public private(set) var textSelection: TextSelection?
    
    init(owner: (any _PlatformTextViewType)?) {
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
            _assignIfNotEqual(owner._caretTextPosition, to: \.positionInText)
            _assignIfNotEqual(owner._SwiftUIX_caretGeometry, to: \.location)
            _assignIfNotEqual(TextSelection(from: owner), to: \.textSelection)
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension _ObservableTextCursor {
    private func subscribeToOwner() {
        
    }
}
#elseif os(macOS)
extension _ObservableTextCursor {
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

extension _ObservableTextCursor {
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
}

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
    var _SwiftUIX_caretGeometry: _CoordinateSpaceRelative<CGRect>? {
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
    
    var _SwiftUIX_selectedRangeGeometry: _CoordinateSpaceRelative<CGRect>? {
        nil //fatalError()
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    var _SwiftUIX_caretGeometry: _CoordinateSpaceRelative<CGRect>? {
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
    
    var _SwiftUIX_selectedRangeGeometry: _CoordinateSpaceRelative<CGRect>? {
        guard let window else {
            return nil
        }

        let selectedRange = self.selectedRange()
        
        guard selectedRange.length > 0 else {
            return nil
        }
                
        let unflippedScreenRect = firstRect(forCharacterRange: selectedRange, actualRange: nil)

        var result = _CoordinateSpaceRelative<CGRect>()
        
        result[.coordinateSpace(.global)] = window.flipLocal(window.convertFromScreen(unflippedScreenRect))
        result[.cocoa(.main)] = NSScreen.flip(unflippedScreenRect)
        
        return result
    }
}
#endif

#endif
