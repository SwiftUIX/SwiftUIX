//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
import SwiftUI

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
class _NSTextView<Label: View>: NSTextView {
    var _cachedIntrinsicContentSize: CGSize? = nil
    var _sizeThatFitsCache: [AppKitOrUIKitLayoutSizeProposal: CGSize] = [:]
    
    var parent: _TextView<Label>!
    
    var configuration: _TextView<Label>.Configuration {
        parent.configuration
    }
    
    override var intrinsicContentSize: CGSize {
        if let _cachedIntrinsicContentSize {
            return _cachedIntrinsicContentSize
        } else {
            guard let result = _sizeThatFits() else {
                return super.intrinsicContentSize
            }
            
            _cachedIntrinsicContentSize = result
            
            return result
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
    }
    
    func _sizeThatFits(
        _ proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        if let cachedResult = _sizeThatFitsCache[proposal] {
            return cachedResult
        }
        
        guard let targetWidth = proposal.size.target.width else {
            assertionFailure("unsupported")
            
            return nil
        }
        
        guard proposal.size.target.width != .zero else {
            return nil
        }
        
        let oldFrame = frame
        
        defer {
            if oldFrame != self.frame {
                self.frame = oldFrame
            }
        }
        
        guard let idealSize = self._sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude)) else {
            return .zero
        }
        
        let result: CGSize
        
        if proposal.fit.horizontal == .required {
            result = CGSize(
                width: min(targetWidth, idealSize.width),
                height: idealSize.height
            )
        } else {
            result = CGSize(
                width: max(targetWidth, idealSize.width),
                height: idealSize.height
            )
        }
        
        if result.isAreaZero {
            return nil
        }
        
        _sizeThatFitsCache[proposal] = result
        
        return result
    }
    
    func _sizeThatFits(_ size: CGSize? = nil) -> CGSize? {
        guard let textContainer = self.textContainer, let layoutManager = self.layoutManager else {
            return nil
        }
        
        if let size, textContainer.containerSize != size {
            textContainer.containerSize = size
        }
        
        layoutManager.ensureLayout(for: textContainer)
        
        let measuredSize = layoutManager.boundingRect(
            forGlyphRange: layoutManager.glyphRange(for: textContainer),
            in: textContainer
        ).size
        
        var extraHeight: CGFloat = 0
        
        if measuredSize.height == 0 || string.hasSuffix("\n") {
            extraHeight += (_heightDifferenceForNewline ?? 0)
        }
        
        let result = CGSize(
            width: measuredSize.width,
            height: measuredSize.height + extraHeight
        )
        
        return result
    }
    
    func _update(
        configuration: _TextView<Label>.Configuration,
        context: _TextView<Label>.Context
    ) {
        _assignIfNotEqual(.clear, to: &backgroundColor)
        _assignIfNotEqual(false, to: &drawsBackground)
        _assignIfNotEqual(!configuration.isConstant && configuration.isEditable, to: &isEditable)
        _assignIfNotEqual(.zero, to: &textContainerInset)
        _assignIfNotEqual(true, to: &usesAdaptiveColorMappingForDarkAppearance)
        
        if let preferredFont = try? configuration.font ?? context.environment.font?.toAppKitOrUIKitFont() {
            _assignIfNotEqual(preferredFont, to: &self.font)
            
            if let textStorage {
                _assignIfNotEqual(preferredFont, to: &textStorage.font)
            }
        }
        
        _assignIfNotEqual(configuration.textColor, to: &textColor)
        
        if let textContainer {
            _assignIfNotEqual(.zero, to: &textContainer.lineFragmentPadding)
            _assignIfNotEqual((context.environment.lineLimit ?? 0), to: &textContainer.maximumNumberOfLines)
        }
        
        _assignIfNotEqual(false, to: &isHorizontallyResizable)
        _assignIfNotEqual(true, to: &isVerticallyResizable)
        _assignIfNotEqual([.width], to: &autoresizingMask)
        
        if let tintColor = configuration.tintColor {
            _assignIfNotEqual(tintColor, to: &insertionPointColor)
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        
        _sizeThatFitsCache = [:]
        _cachedIntrinsicContentSize = nil
    }
    
    override func preferredPasteboardType(
        from availableTypes: [NSPasteboard.PasteboardType],
        restrictedToTypesFrom allowedTypes: [NSPasteboard.PasteboardType]?
    ) -> NSPasteboard.PasteboardType? {
        if availableTypes.contains(.string) {
            return .string
        } else {
            return super.preferredPasteboardType(
                from: availableTypes,
                restrictedToTypesFrom: allowedTypes
            )
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let shortcut = KeyboardShortcut(from: event) {
            switch shortcut {
                case KeyboardShortcut(.return, modifiers: []):
                    configuration.onCommit()
                default:
                    super.keyDown(with: event)
            }
        } else {
            super.keyDown(with: event)
        }
    }
}
#endif
