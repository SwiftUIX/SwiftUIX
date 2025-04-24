//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import _SwiftUIX
import AppKit
import SwiftUI

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _AnyPlatformTextView {
    public static func updateAppKitOrUIKitTextView(
        _ view: AppKitOrUIKitTextView,
        data: _TextViewDataBinding,
        textViewConfiguration: _TextViewConfiguration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        guard let view = view as? _AnyPlatformTextView else {
            assertionFailure("unsupported")
            
            return
        }
        
        view._updatePlatformTextView(
            data: data,
            textViewConfiguration: textViewConfiguration,
            context: context
        )
    }
        
    private func _updatePlatformTextView(
        data: _TextViewDataBinding,
        textViewConfiguration: _TextViewConfiguration,
        context: any _AppKitOrUIKitViewRepresentableContext
    ) {
        _assignIfNotEqual(true, to: \.allowsUndo)
        _assignIfNotEqual(.clear, to: \.backgroundColor)
        _assignIfNotEqual(false, to: \.drawsBackground)
        _assignIfNotEqual(!textViewConfiguration.isConstant && textViewConfiguration.isEditable, to: \.isEditable)
        _assignIfNotEqual(.zero, to: \.textContainerInset)
        _assignIfNotEqual(true, to: \.usesAdaptiveColorMappingForDarkAppearance)
        _assignIfNotEqual(textViewConfiguration.isSelectable, to: \.isSelectable)

        if let automaticQuoteSubstitutionDisabled = textViewConfiguration.automaticQuoteSubstitutionDisabled {
            _assignIfNotEqual(!automaticQuoteSubstitutionDisabled, to: \.isAutomaticQuoteSubstitutionEnabled)
        }
        
        if let font: AppKitOrUIKitFont = try? textViewConfiguration.cocoaFont ?? context.environment.font?.toAppKitOrUIKitFont() {
            _assignIfNotEqual(font, to: \.self.font)
            
            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(font, to: \.font)
            }
            
            if let typingAttribute = typingAttributes[NSAttributedString.Key.font] as? AppKitOrUIKitFont, typingAttribute != font {
                typingAttributes[NSAttributedString.Key.font] = font
                typingAttributes[NSAttributedString.Key.paragraphStyle] = defaultParagraphStyle
            }
        }
                
        if let foregroundColor: AppKitOrUIKitColor = textViewConfiguration.cocoaForegroundColor {
            _assignIfNotEqual(foregroundColor, to: \.textColor)

            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(foregroundColor, to: \.foregroundColor)
            }
            
            if let typingAttribute: AppKitOrUIKitColor = typingAttributes[NSAttributedString.Key.foregroundColor] as? AppKitOrUIKitColor, typingAttribute != foregroundColor {
                typingAttributes[NSAttributedString.Key.foregroundColor] = foregroundColor
                typingAttributes[NSAttributedString.Key.paragraphStyle] = defaultParagraphStyle
            }
        }
        
        if let textContainer: NSTextContainer = _SwiftUIX_textContainer {
            textContainer._assignIfNotEqual(.zero, to: \.lineFragmentPadding)
            textContainer._assignIfNotEqual(context.environment.lineBreakMode, to: \.lineBreakMode)
            textContainer._assignIfNotEqual((context.environment.lineLimit ?? 0), to: \.maximumNumberOfLines)
        }
        
        setLineSpacing(context.environment.lineSpacing)
        
        _assignIfNotEqual(false, to: \.isHorizontallyResizable)
        _assignIfNotEqual(true, to: \.isVerticallyResizable)
        _assignIfNotEqual([.width], to: \.autoresizingMask)
        
        if let tintColor = textViewConfiguration.tintColor {
            _assignIfNotEqual(tintColor, to: \.insertionPointColor)
        }
        
        if _currentTextViewData(kind: self.data.wrappedValue.kind) != data.wrappedValue {
            _needsIntrinsicContentSizeInvalidation = true
            
            if !_providesCustomSetDataValueMethod {
                setDataValue(data.wrappedValue)
            }
        }
        
        self.data = data
        self.textViewConfiguration = textViewConfiguration
        
        _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded()
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _AnyPlatformTextView {
    private func _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded() {
        defer {
            _needsIntrinsicContentSizeInvalidation = false
            _wantsRelayout = false
        }
        
        guard let textContainer = textContainer, !_SwiftUIX_intrinsicContentSizeIsDisabled else {
            return
        }
                        
        if _needsIntrinsicContentSizeInvalidation {
            if !_SwiftUIX_intrinsicContentSizeIsDisabled {
                invalidateIntrinsicContentSize()
            }
            
            /*if let intrinsicContentSize = _computeIntrinsicContentSize() {
                self.representableCache._cachedIntrinsicContentSize = intrinsicContentSize
                
                _enforcePrecomputedIntrinsicContentSize()
            }*/
        }
        
        if _wantsRelayout {
            _SwiftUIX_layoutManager?.ensureLayout(for: textContainer)
            
            if _needsIntrinsicContentSizeInvalidation {
                _SwiftUIX_setNeedsLayout()
                _SwiftUIX_layoutIfNeeded()
            }
        }
    }
    
    private func _computeIntrinsicContentSize() -> CGSize? {
        if let _fixedSize = textViewConfiguration._fixedSize {
            switch _fixedSize.value {
                case (false, false):
                    return nil
                case (false, true):
                    return nil
                default:
                    assertionFailure("\(_fixedSize) is currently unsupported.")
                    
                    break
            }
        }
        
        guard frame.width.isNormal else {
            return nil
        }
        
        let oldIntrinsicContentSize: CGSize? = self.intrinsicContentSize
        let proposal = AppKitOrUIKitLayoutSizeProposal(width: frame.size.width, height: nil)
        let intrinsicContentSize: CGSize?
        
        if let cached = representableCache.sizeThatFits(proposal: proposal) {
            intrinsicContentSize = cached.toAppKitOrUIKitIntrinsicContentSize()
        } else {
            intrinsicContentSize = _sizeThatFits(proposal: proposal)?.toAppKitOrUIKitIntrinsicContentSize()
            
            if let oldIntrinsicContentSize, let intrinsicContentSize {
                if intrinsicContentSize.width == oldIntrinsicContentSize.width || intrinsicContentSize.width == frame.width {
                    representableCache._sizeThatFitsCache[.init(width: self.frame.width, height: nil)] = intrinsicContentSize
                    representableCache._sizeThatFitsCache[.init(width: nil, height: nil)] = intrinsicContentSize
                }
            }
        }
        
        guard let intrinsicContentSize else {
            return nil
        }
        
        return intrinsicContentSize
    }
    
    private func _enforcePrecomputedIntrinsicContentSize() {
        guard let intrinsicContentSize = representableCache._cachedIntrinsicContentSize, !intrinsicContentSize._hasUnspecifiedIntrinsicContentSizeDimensions else {
            return
        }
        
        if frame.size.width < intrinsicContentSize.width {
            frame.size.width = intrinsicContentSize.width
        }
        
        if frame.size.height < intrinsicContentSize.height {
            frame.size.height = intrinsicContentSize.height
        }
    }
    
    private func _correctNSTextContainerSize() {
        guard let textContainer: NSTextContainer else {
            return
        }
        
        if let fixedSize: _SwiftUIX_FixedSizeInfo = textViewConfiguration._fixedSize {
            if fixedSize.value == (false, false) {
                if textContainer.heightTracksTextView == false {
                    textContainer.widthTracksTextView = true
                    textContainer.heightTracksTextView = true
                }
                
                if textContainer.size.height != 10000000.0 {
                    textContainer.size.height = 10000000.0
                }
            } else {
                assertionFailure("unsupported")
            }
        }
    }
}

// MARK: - Auxiliary

extension NSTextView {
    func setLineSpacing(_ lineSpacing: CGFloat) {
        if defaultParagraphStyle == nil && lineSpacing == 0 {
            return
        }
        
        if defaultParagraphStyle?.lineSpacing == lineSpacing {
            return
        }
                
        let newParagraphStyle = (self.defaultParagraphStyle as? NSMutableParagraphStyle) ?? (self.defaultParagraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        
        newParagraphStyle.lineSpacing = lineSpacing
        
        defaultParagraphStyle = newParagraphStyle
        typingAttributes[.paragraphStyle] = newParagraphStyle
    }
}

#endif
