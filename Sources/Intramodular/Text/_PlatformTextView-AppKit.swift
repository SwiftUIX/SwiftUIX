//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public static func updateAppKitOrUIKitTextView(
        _ view: AppKitOrUIKitTextView,
        data: _TextViewDataBinding,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        guard let view = view as? _PlatformTextView else {
            assertionFailure("unsupported")
            
            return
        }
        
        view._update(data: data, configuration: configuration, context: context)
    }
    
    private func _update(
        data: _TextViewDataBinding,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        _assignIfNotEqual(true, to: \.allowsUndo)
        _assignIfNotEqual(.clear, to: \.backgroundColor)
        _assignIfNotEqual(false, to: \.drawsBackground)
        _assignIfNotEqual(!configuration.isConstant && configuration.isEditable, to: \.isEditable)
        _assignIfNotEqual(.zero, to: \.textContainerInset)
        _assignIfNotEqual(true, to: \.usesAdaptiveColorMappingForDarkAppearance)
        
        if let font = try? configuration.cocoaFont ?? context.environment.font?.toAppKitOrUIKitFont() {
            _assignIfNotEqual(font, to: \.self.font)
            
            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(font, to: \.font)
            }
        }
        
        _assignIfNotEqual(configuration.cocoaForegroundColor, to: \.textColor)
        
        if let foregroundColor = configuration.cocoaForegroundColor {
            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(foregroundColor, to: \.foregroundColor)
            }
        }
        
        if let textContainer {
            textContainer._assignIfNotEqual((context.environment.lineLimit ?? 0), to: \.maximumNumberOfLines)
        }
        
        _assignIfNotEqual(false, to: \.isHorizontallyResizable)
        _assignIfNotEqual(true, to: \.isVerticallyResizable)
        _assignIfNotEqual([.width], to: \.autoresizingMask)
        
        if let tintColor = configuration.tintColor {
            _assignIfNotEqual(tintColor, to: \.insertionPointColor)
        }
        
        if _currentTextViewData(kind: self.data.wrappedValue.kind) != data.wrappedValue {
            _needsIntrinsicContentSizeInvalidation = true
            
            setDataValue(data.wrappedValue)
        }
        
        self.data = data
        self.configuration = configuration
        
        _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded()
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    private func _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded() {
        guard let textContainer = textContainer else {
            return
        }
        
        if _needsIntrinsicContentSizeInvalidation {
            invalidateIntrinsicContentSize()
            
            if let intrinsicContentSize = _computeIntrinsicContentSize() {
                self.representableCache._cachedIntrinsicContentSize = intrinsicContentSize
                
                _enforcePrecomputedIntrinsicContentSize()
            }
        }
        
        if _wantsRelayout {
            _SwiftUIX_layoutManager?.ensureLayout(for: textContainer)
            
            if _needsIntrinsicContentSizeInvalidation {
                _SwiftUIX_setNeedsLayout()
                _SwiftUIX_layoutIfNeeded()
            }
        }
        
        _needsIntrinsicContentSizeInvalidation = false
        _wantsRelayout = false
    }
    
    private func _computeIntrinsicContentSize() -> CGSize? {
        if let _fixedSize = configuration._fixedSize {
            switch _fixedSize {
                case (false, false):
                    return nil
                default:
                    assertionFailure()
                    
                    break
            }
        }
        
        guard frame.width.isNormal else {
            return nil
        }
        
        let proposal = AppKitOrUIKitLayoutSizeProposal(width: frame.size.width, height: nil)
        let intrinsicContentSize: CGSize?
        
        if let cached = representableCache.sizeThatFits(proposal: proposal) {
            intrinsicContentSize = cached.toAppKitOrUIKitIntrinsicContentSize()
        } else {
            intrinsicContentSize = _sizeThatFits(proposal: proposal)?.toAppKitOrUIKitIntrinsicContentSize()
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
        guard let textContainer else {
            return
        }
        
        if let fixedSize = configuration._fixedSize {
            if fixedSize == (false, false) {
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

#endif
