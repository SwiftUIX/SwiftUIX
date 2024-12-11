//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public static func updateAppKitOrUIKitTextView(
        _ view: AppKitOrUIKitTextView,
        data: _TextViewDataBinding,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        #if os(visionOS)
        view.hoverStyle = .none
        #endif

        let requiresAttributedText: Bool = false
            || context.environment._textView_requiresAttributedText
            || configuration.requiresAttributedText
            || data.wrappedValue.isAttributed
        
        var cursorOffset: Int?
        
        // Record the current cursor offset.
        if let selectedRange = view.selectedTextRange {
            cursorOffset = view.offset(from: view.beginningOfDocument, to: selectedRange.start)
        }
        
    updateUserInteractability: do {
        #if !os(tvOS)
        if !configuration.isEditable {
            view.isEditable = false
        } else {
            view.isEditable = configuration.isConstant
            ? false
            : context.environment.isEnabled && configuration.isEditable
        }
        #endif
        view.isScrollEnabled = context.environment._isScrollEnabled
        view.isSelectable = configuration.isSelectable
    }
        
    updateLayoutConfiguration: do {
        (view as? _PlatformTextView<Label>)?.preferredMaximumDimensions = context.environment.preferredMaximumLayoutDimensions
    }
        
    updateTextAndGeneralConfiguration: do {
        if #available(iOS 14.0, tvOS 14.0, *) {
            view.overrideUserInterfaceStyle = .init(context.environment.colorScheme)
        }
        
        view.autocapitalizationType = configuration.autocapitalization ?? .sentences
        
        let font: AppKitOrUIKitFont? = configuration.cocoaFont ?? (try? context.environment.font?.toAppKitOrUIKitFont())
        
        if let textColor = configuration.cocoaForegroundColor {
            view._assignIfNotEqual(textColor, to: \.textColor)
        }
        
        if let tintColor = configuration.tintColor {
            view._assignIfNotEqual(tintColor, to: \.tintColor)
        }
        
        if let linkForegroundColor = configuration.linkForegroundColor {
            SwiftUIX._assignIfNotEqual(linkForegroundColor, to: &view.linkTextAttributes[.foregroundColor])
        } else {
            if view.linkTextAttributes[.foregroundColor] != nil {
                view.linkTextAttributes[.foregroundColor] = nil
            }
        }
        
        view.textContentType = configuration.textContentType
        
        view.textContainer.lineFragmentPadding = .zero
        view.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
        view.textContainerInset = AppKitOrUIKitEdgeInsets(configuration.textContainerInsets)
        
        if data.wrappedValue.kind != .cocoaTextStorage {
            if requiresAttributedText {
                let paragraphStyle = NSMutableParagraphStyle()
                
                paragraphStyle._assignIfNotEqual(context.environment.lineBreakMode, to: \.lineBreakMode)
                paragraphStyle._assignIfNotEqual(context.environment.lineSpacing, to: \.lineSpacing)
                
                context.environment._textView_paragraphSpacing.map {
                    paragraphStyle.paragraphSpacing = $0
                }
                
                func attributedStringAttributes() -> [NSAttributedString.Key: Any] {
                    var attributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                    
                    if let font {
                        attributes[.font] = font
                    }
                    
                    if let kerning = configuration.kerning {
                        attributes[.kern] = kerning
                    }
                    
                    if let textColor = configuration.cocoaForegroundColor {
                        attributes[.foregroundColor] = textColor
                    }
                    
                    return attributes
                }
                
                view.attributedText = data.wrappedValue.toAttributedString(attributes: attributedStringAttributes())
            } else {
                if let text = data.wrappedValue.stringValue {
                    view.text = text
                } else {
                    assertionFailure()
                }
                
                view.font = font
            }
        }
    }
        
    correctCursorOffset: do {
        #if os(tvOS)
        if let cursorOffset = cursorOffset, let position = view.position(from: view.beginningOfDocument, offset: cursorOffset), let textRange = view.textRange(from: position, to: position) {
            view.selectedTextRange = textRange
        }
        #else
        // Reset the cursor offset if possible.
        if view.isEditable, let cursorOffset = cursorOffset, let position = view.position(from: view.beginningOfDocument, offset: cursorOffset), let textRange = view.textRange(from: position, to: position) {
            view.selectedTextRange = textRange
        }
        #endif
    }
        
    updateKeyboardConfiguration: do {
        view.enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically ?? false
        view.keyboardType = configuration.keyboardType
        view.returnKeyType = configuration.returnKeyType ?? .default
    }
        
    updateResponderChain: do {
        DispatchQueue.main.async {
            if let isFocused = configuration.isFocused, view.window != nil {
                if isFocused.wrappedValue && !view.isFirstResponder {
                    view.becomeFirstResponder()
                } else if !isFocused.wrappedValue && view.isFirstResponder {
                    view.resignFirstResponder()
                }
            } else if let isFirstResponder = configuration.isFirstResponder, view.window != nil {
                if isFirstResponder && !view.isFirstResponder, context.environment.isEnabled {
                    view.becomeFirstResponder()
                } else if !isFirstResponder && view.isFirstResponder {
                    view.resignFirstResponder()
                }
            }
        }
    }
        
        (view as? _PlatformTextView<Label>)?.data = data
        (view as? _PlatformTextView<Label>)?.configuration = configuration
    }
    
    func _sizeThatFits(_ size: CGSize? = nil) -> CGSize? {
        if let size {
            return self.sizeThatFits(size)
        } else {
            if let preferredMaximumLayoutWidth = preferredMaximumDimensions.width {
                return sizeThatFits(
                    CGSize(
                        width: preferredMaximumLayoutWidth,
                        height: AppKitOrUIKitView.layoutFittingCompressedSize.height
                    )
                    .clamped(to: preferredMaximumDimensions)
                )
            } else if !isScrollEnabled {
                return .init(
                    width: bounds.width,
                    height: _sizeThatFitsWidth(bounds.width)?.height ?? AppKitOrUIKitView.noIntrinsicMetric
                )
            } else {
                return .init(
                    width: AppKitOrUIKitView.noIntrinsicMetric,
                    height: min(
                        preferredMaximumDimensions.height ?? contentSize.height,
                        contentSize.height
                    )
                )
            }
        }
    }
    
    func verticallyCenterTextIfNecessary() {
        guard !isScrollEnabled else {
            return
        }
        
        guard let _cachedIntrinsicContentSize = representableCache._cachedIntrinsicContentSize else {
            return
        }
        
        guard let intrinsicHeight = OptionalDimensions(intrinsicContentSize: _cachedIntrinsicContentSize).height else {
            return
        }
        
        let topOffset = (bounds.size.height - intrinsicHeight * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        
        contentOffset.y = -positiveTopOffset
    }
}

#endif
