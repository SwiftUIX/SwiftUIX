//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitTextView {
    func _SwiftUIX_replaceTextStorage(_ textStorage: NSTextStorage) {
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.replaceLayoutManager(layoutManager)
        
        assert(self.textStorage == textStorage)
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
        
        if layoutManager != _SwiftUIX_layoutManager {
            textContainer?.replaceLayoutManager(layoutManager)
        }
        
        layoutManager.replaceTextStorage(textStorage)
        
        assert(self.textStorage == textStorage)
        assert(self.layoutManager == layoutManager)
        
        setSelectedRange(NSRange(location: string.count, length: 0))
    }
}
#endif

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public func invalidateLayout(
        for range: NSRange
    ) {
        guard let layoutManager = _SwiftUIX_layoutManager else {
            return
        }
        
        layoutManager.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
    }
    
    public func invalidateDisplay(
        for range: NSRange
    ) {
        _SwiftUIX_layoutManager?.invalidateDisplay(forCharacterRange: range)
    }
    
    public func _ensureLayoutForTextContainer() {
        if let textContainer = _SwiftUIX_textContainer {
            _SwiftUIX_layoutManager?.invalidateLayout(forCharacterRange: .init(location: 0, length: _SwiftUIX_attributedText.length), actualCharacterRange: nil)
            _SwiftUIX_layoutManager?.ensureLayout(for: textContainer)
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension NSTextContainer {
    var containerSize: CGSize {
        get {
            size
        } set {
            size = newValue
        }
    }
}

extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = EditActions
}
#elseif os(macOS)
extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = NSTextStorageEditActions
}
#endif

extension NSTextContainer {
    @_spi(Internal)
    public var _hasNormalContainerWidth: Bool {
        containerSize.width.isNormal && containerSize.width != 10000000.0
    }
}

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
