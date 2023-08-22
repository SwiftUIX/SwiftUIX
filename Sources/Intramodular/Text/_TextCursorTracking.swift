//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public final class _TextCursorTracking: ObservableObject {
    private weak var owner: (any _PlatformTextView_Type)?
    
    @Published public private(set) var location: Int?
    @Published public private(set) var bounds: CGRect?
    
    init(owner: (any _PlatformTextView_Type)?) {
        self.owner = owner
        
        subscribeToOwner()
        update()
    }
    
    /// Update the tracking state by copying from the owner.
    @_spi(Internal)
    public func update() {
        self.location = owner?._caretLocation
        self.bounds = owner?._cocoaCaretBoundsInWindow
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
        guard (notification.object as? NSTextView) === owner else {
            return
        }
        
        update()
    }
}
#endif

// MARK: - Auxiliary

extension AppKitOrUIKitTextView {
    var _caretLocation: Int? {
        _SwiftUIX_selectedRange.length > 0 ? nil : selectedRange.location
    }
}
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    var _cocoaCaretBoundsInWindow: CGRect? {
        fatalError("unimplemented")
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    var _cocoaCaretBoundsInWindow: CGRect? {
        guard let window else {
            return nil
        }

        let selectedRange = selectedRange()
        
        if selectedRange.length > 0 {
            return nil
        } else {
            let unflippedScreenRect = firstRect(forCharacterRange: selectedRange, actualRange: nil)
                        
            var rect = window.flip(window.convertFromScreen(unflippedScreenRect))
            
            if rect.width == 0 {
                rect.size.width = 1
            }
            
            return rect
        }
    }
}
#endif

#endif
