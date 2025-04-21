//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import SwiftUI

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {    
    public func _ensureLayoutForTextContainer() {
        guard let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
            return
        }
        
        if let textContainer: NSTextContainer = _SwiftUIX_textContainer {
            layoutManager.invalidateLayout(
                forCharacterRange: .init(location: 0, length: _SwiftUIX_attributedText.length),
                actualCharacterRange: nil
            )
            
            layoutManager.ensureLayout(for: textContainer)
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    func _SwiftUIX_replaceTextStorage(
        _ newTextStorage: NSTextStorage
    ) {
        assert(self.textStorage !== newTextStorage)
        
        let currentLayoutManager: NSLayoutManager = self.layoutManager
        
        currentLayoutManager._SwiftUIX_replaceTextStorage(newTextStorage)
        
        assert(self.textStorage === newTextStorage)
    }
}
#elseif os(macOS)
extension AppKitOrUIKitTextView {
    func _SwiftUIX_replaceTextStorage(
        _ textStorage: NSTextStorage
    ) {
        guard let layoutManager = (self as? (any _PlatformTextViewType))?._SwiftUIX_makeLayoutManager() ?? _SwiftUIX_layoutManager else {
            assertionFailure()
            
            return
        }
        
        guard let textContainer: NSTextContainer = _SwiftUIX_textContainer else {
            assertionFailure()
            
            return
        }
        
        if layoutManager != _SwiftUIX_layoutManager {
            textContainer.replaceLayoutManager(layoutManager)
        }
        
        layoutManager.replaceTextStorage(textStorage)
        
        assert(self.textStorage == textStorage)
        assert(self.layoutManager == layoutManager)
        
        setSelectedRange(NSRange(location: string.count, length: 0))
    }
}
#endif

// MARK: - Internal

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension NSLayoutManager {
    fileprivate func _SwiftUIX_replaceTextStorage(_ newTextStorage: NSTextStorage) {
        textStorage?.removeLayoutManager(self)
        
        for manager in textStorage?.layoutManagers ?? [] {
            manager.textStorage = newTextStorage
        }
        
        newTextStorage.addLayoutManager(self)
        
        textStorage = newTextStorage
    }
}
#endif

extension EnvironmentValues {
    @_spi(Internal)
    public var _textView_requiresAttributedText: Bool {
        _textView_paragraphSpacing != nil
    }
}

private extension CGSize {
    var edgeInsets: EdgeInsets {
        .init(
            top: height / 2,
            leading: width / 2,
            bottom: height / 2,
            trailing: width / 2
        )
    }
}

#endif
