//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import Combine
import Swift
import SwiftUI

extension _TextView {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        guard let view = view as? _PlatformTextView<Label> else {
            return nil // TODO: Implement sizing for custom text views as well
        }
        
        guard !view.representatableStateFlags.contains(.dismantled) else {
            return nil
        }
        
        let proposal = AppKitOrUIKitLayoutSizeProposal(
            proposal,
            fixedSize: resolvedTextViewConfiguration._fixedSize?.value
        )
        
        guard let size: CGSize = view._sizeThatFits(proposal: proposal) else {
            return nil
        }
        
        return size
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _AnyPlatformTextView {
    func _sizeThatFits(
        proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        guard let targetWidth: CGFloat = proposal.replacingUnspecifiedDimensions(by: .zero).targetWidth else {
            assertionFailure()
            
            return nil
        }
                
        if let _fixedSize: _SwiftUIX_FixedSizeInfo = textViewConfiguration._fixedSize {
            if _fixedSize.value == (false, false) {
                return nil
            }
        }
        
        if let cached: CGSize = representableCache.sizeThatFits(proposal: proposal) {
            return cached
        } else {
            assert(proposal.size.maximum == nil)
            
            let _sizeThatFits: CGSize? = _uncachedSizeThatFits(for: targetWidth)
            
            guard var result: CGSize = _sizeThatFits else {
                if targetWidth == 0 {
                    return nil
                } else {
                    return nil
                }
            }
            
            if !result._hasPlaceholderDimension(.width, for: .textContainer) {
                var _result = result._filterPlaceholderDimensions(for: .textContainer)
                
                if let _fixedSize: _SwiftUIX_FixedSizeInfo = textViewConfiguration._fixedSize {
                    switch _fixedSize.value {
                        case (false, false):
                            if (_result.width ?? 0) < targetWidth {
                                _result.width = targetWidth
                            }
                            
                            if let targetHeight: CGFloat = proposal.targetHeight, (_result.height ?? 0) < targetHeight {
                                _result.height = targetHeight
                            }
                        case (false, true):
                            if (_result.width ?? 0) < targetWidth {
                                if _numberOfLinesOfWrappedTextDisplayed > 1 {
                                    _result.width = targetWidth
                                }
                            }
                            
                            if let targetHeight: CGFloat = proposal.targetHeight, (_result.height ?? 0) < targetHeight {
                                _result.height = targetHeight
                            }
                        default:
                            assertionFailure()
                            
                            break
                    }
                } else {
                    _result.width = max(result.width, targetWidth)
                }
                
                guard let _result = CGSize(_result) else {
                    return nil
                }
                
                result = _result
            } else {
                guard !targetWidth.isPlaceholderDimension(for: .textContainer) else {
                    return nil
                }
                
                result.width = targetWidth
            }
            
            representableCache._sizeThatFitsCache[proposal] = result
            
            if result._isNormal {
                if frame.size != result {
                    frame.size = result
                }
            }
            
            return result
        }
    }
    
    private func _uncachedSizeThatFits(
        for width: CGFloat
    ) -> CGSize? {
        guard
            let textContainer: NSTextContainer = _SwiftUIX_textContainer,
            let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager
        else {
            return nil
        }
        
        if
            !representableCache._sizeThatFitsCache.isEmpty,
            textContainer.containerSize.width == width,
            textContainer._hasNormalContainerWidth
        {
            let usedRect: CGRect = layoutManager.usedRect(for: textContainer)
            
            /// DO NOT REMOVE.
            if usedRect.size.isAreaZero {
                return _sizeThatFitsWidth(width)
            }
            
            return usedRect.size
        } else {
            return _sizeThatFitsWidth(width)
        }
    }
}

extension AppKitOrUIKitTextView {
    func _sizeThatFitsWidth(
        _ width: CGFloat
    ) -> CGSize? {
        _sizeThatFitsWithoutCopying(width: width)
    }
    
    private func _sizeThatFitsWithoutCopying(
        width: CGFloat
    ) -> CGSize? {
        guard
            let textContainer: NSTextContainer = _SwiftUIX_textContainer,
            let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager,
            let textStorage: NSTextStorage = _SwiftUIX_textStorage
        else {
            return nil
        }
        
        guard width != 0 else {
            return nil
        }
        
        let originalSize: CGSize = frame.size
        let originalTextContainerSize: CGSize = textContainer.containerSize
        
        guard width.isNormal && width != .greatestFiniteMagnitude else {
            return nil
        }
        
        // frame.size.width = width
        textContainer.containerSize = CGSize(width: width, height: 10000000.0)
        
        defer {
            textContainer.containerSize = originalTextContainerSize
            
            if frame.size.width != originalSize.width {
                frame.size.width = originalSize.width
            }
        }
        
        /*layoutManager.invalidateLayout(
            forCharacterRange: NSRange(location: 0, length: textStorage.length),
            actualCharacterRange: nil
        )*/
        
        /// Uncommenting out this line without also uncommenting out `frame.size.width = width` will result in placeholder max width being returned.
        // let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        layoutManager.ensureLayout(for: textContainer)
        
        let usedRect: CGRect = layoutManager.usedRect(for: textContainer)
        // let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        if usedRect.isEmpty {
            if (!width.isNormal && !textStorage.string.isEmpty) {
                return nil
            }
            
            guard textStorage.string.isEmpty else {
                frame.size.width = width
                
                defer {
                    frame.size.width = originalSize.width
                }
                
                layoutManager.ensureLayout(for: textContainer)
                
                let usedRect2 = layoutManager.usedRect(for: textContainer)
                
                guard !usedRect2.isEmpty else {
                    return nil
                }
                
                if usedRect2.size._hasPlaceholderDimensions(for: .textContainer) {
                    assertionFailure()
                }
                
                return usedRect2.size
            }
        }
        
        if usedRect.size._hasPlaceholderDimensions(for: .textContainer) {
            return usedRect.size
        }
        
        return usedRect.size
    }
    
    private func _sizeThatFitsByCopying(
        width: CGFloat,
        accountForNewline: Bool
    ) -> CGSize? {
        guard let textContainer = _SwiftUIX_textContainer, let textStorage = _SwiftUIX_textStorage else {
            return nil
        }
        
        let temporaryTextStorage = NSTextStorage(attributedString: textStorage)
        let width: CGFloat = bounds.width - textContainerInset.horizontal
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let temporaryTextContainer = NSTextContainer(size: containerSize)
        let temporaryLayoutManager = NSLayoutManager()
        
        temporaryLayoutManager.addTextContainer(temporaryTextContainer)
        temporaryTextStorage.addLayoutManager(temporaryLayoutManager)
        
        temporaryTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        temporaryTextContainer.lineBreakMode = textContainer.lineBreakMode
        
        _ = temporaryLayoutManager.glyphRange(for: temporaryTextContainer)
        
        let usedRect = temporaryLayoutManager.usedRect(for: temporaryTextContainer)
        
        var result = CGSize(
            width: ceil(usedRect.size.width + textContainerInset.horizontal),
            height: ceil(usedRect.size.height + textContainerInset.vertical)
        )
        
        if accountForNewline {
            if temporaryTextStorage.string.hasSuffix("\n") {
                result.height += (_heightDifferenceForNewline ?? 0)
            }
        }
        
        return result
    }
}

#endif
