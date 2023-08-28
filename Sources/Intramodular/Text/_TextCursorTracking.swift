//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public final class _TextCursorTracking: ObservableObject {
    private weak var owner: (any _PlatformTextView_Type)?
    
    @Published public private(set) var positionInText: Int?
    @_spi(Internal)
    @Published public private(set) var location: _CoordinateSpaceSpecific<CGRect>?

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

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
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
}
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    var _SwiftUIX_caretLocation: _CoordinateSpaceSpecific<CGRect>? {
        guard let selectedRange = selectedTextRange else {
            return nil
        }

        guard selectedRange.isEmpty else {
            return nil
        }
        
        var result = _CoordinateSpaceSpecific<CGRect>()

        result[.coordinateSpace(.global)] = caretRect(for: selectedRange.start)

        return result
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    var _SwiftUIX_caretLocation: _CoordinateSpaceSpecific<CGRect>? {
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

            var result = _CoordinateSpaceSpecific<CGRect>()
            
            result[.coordinateSpace(.global)] = window.flipLocal(window.convertFromScreen(unflippedScreenRect))
            result[.screen(.main)] = NSScreen.flip(unflippedScreenRect)

            return result
        }
    }
}
#endif

#endif
