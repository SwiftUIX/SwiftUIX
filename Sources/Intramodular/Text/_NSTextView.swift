//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
import SwiftUI

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
class _NSTextView<Label: View>: NSTextView {
    var parent: _TextView<Label>!
    
    var configuration: _TextView<Label>.Configuration {
        parent.configuration
    }
    
    override var intrinsicContentSize: NSSize {
        guard let manager = textContainer?.layoutManager else {
            return .zero
        }
        
        manager.ensureLayout(for: textContainer!)
        
        let size = manager.usedRect(for: textContainer!).size
        
        return NSSize(width: size.width, height: size.height)
    }
    
    func _sizeThatFits(
        _ proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> NSSize? {
        guard let targetWidth = proposal.size.target.width else {
            assertionFailure("unsupported")
            
            return nil
        }
        
        guard proposal.size.target.width != .zero else {
            return nil
        }
        
        guard let idealSize = self._sizeThatFits(forWidth: targetWidth) else {
            return .zero
        }
        
        var additionalHeight: CGFloat?
        
        if let font = self.font {
            if idealSize.height == 0 || string.hasSuffix("\n") {
                additionalHeight = font.ascender + font.descender + font.leading
            }
        }
        
        let result: CGSize
        
        if proposal.fit.horizontal == .required {
            result = CGSize(
                width: min(targetWidth, idealSize.width),
                height: idealSize.height + (additionalHeight ?? 0)
            )
        } else {
            result = CGSize(
                width: max(targetWidth, idealSize.width),
                height: idealSize.height + (additionalHeight ?? 0)
            )
        }
        
        if result.isAreaZero {
            return nil
        }
                
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
                    parent.configuration.onCommit()
                default:
                    super.keyDown(with: event)
            }
        } else {
            super.keyDown(with: event)
        }
    }
}
#endif
