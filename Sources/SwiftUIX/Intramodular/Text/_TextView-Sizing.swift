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
        
        guard let size = view._sizeThatFits(
            proposal: AppKitOrUIKitLayoutSizeProposal(
                proposal,
                fixedSize: textViewConfiguration._fixedSize?.value
            )
        ) else {
            return nil
        }
        
        return size
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    func _sizeThatFits(
        proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        guard let targetWidth = proposal.replacingUnspecifiedDimensions(by: .zero).targetWidth else {
            assertionFailure()
            
            return nil
        }
        
        if let _fixedSize = configuration._fixedSize {
            if _fixedSize.value == (false, false) {
                return nil
            }
        }
        
        if let cached = representableCache.sizeThatFits(proposal: proposal) {
            return cached
        } else {
            assert(proposal.size.maximum == nil)
            
            let _sizeThatFits: CGSize? = _uncachedSizeThatFits(for: targetWidth)
            
            guard var result: CGSize = _sizeThatFits else {
                return nil
            }
            
            if !result._hasPlaceholderDimension(.width, for: .textContainer) {
                var _result = result._filterPlaceholderDimensions(for: .textContainer)
                
                if let _fixedSize = configuration._fixedSize {
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
            
            return result
        }
    }
    
    private func _uncachedSizeThatFits(
        for width: CGFloat
    ) -> CGSize? {
        guard let textContainer: NSTextContainer = _SwiftUIX_textContainer, let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
            return nil
        }
        
        if
            !representableCache._sizeThatFitsCache.isEmpty,
            textContainer.containerSize.width == width,
            textContainer._hasNormalContainerWidth
        {
            let usedRect = layoutManager.usedRect(for: textContainer).size
            
            /// DO NOT REMOVE.
            if usedRect.isAreaZero {
                return _sizeThatFitsWidth(width)
            }
            
            return usedRect
        } else {
            return _sizeThatFitsWidth(width)
        }
    }
}

#endif
