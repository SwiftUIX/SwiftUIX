//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public class UIHostingTextView<Label: View>: UITextView {
    private var _cachedIntrinsicContentSize: CGSize?
    private var lastBounds: CGSize = .zero
    
    public override var attributedText: NSAttributedString! {
        didSet {
            if preferredMaximumDimensions.height != nil {
                if isScrollEnabled {
                    DispatchQueue.main.async {
                        self.invalidateIntrinsicContentSize()
                    }
                }
            }
        }
    }
    
    public var preferredMaximumDimensions: OptionalDimensions = nil {
        didSet {
            let desiredHorizontalContentHuggingPriority = preferredMaximumDimensions.width == nil
                ? AppKitOrUIKitLayoutPriority.defaultLow
                : AppKitOrUIKitLayoutPriority.defaultHigh
            
            if contentHuggingPriority(for: .horizontal) != desiredHorizontalContentHuggingPriority {
                setContentHuggingPriority(
                    desiredHorizontalContentHuggingPriority,
                    for: .horizontal
                )
            }
            
            let desiredVerticalContentHuggingPriority = preferredMaximumDimensions.height == nil
                ? AppKitOrUIKitLayoutPriority.defaultLow
                : AppKitOrUIKitLayoutPriority.defaultHigh
            
            if contentHuggingPriority(for: .vertical) != desiredVerticalContentHuggingPriority {
                setContentHuggingPriority(
                    desiredVerticalContentHuggingPriority,
                    for: .vertical
                )
            }
            
            if (oldValue.width != nil || oldValue.height != nil), preferredMaximumDimensions != oldValue {
                invalidateIntrinsicContentSize()
                
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        computeIntrinsicContentSize() ?? super.intrinsicContentSize
    }
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func invalidateIntrinsicContentSize() {
        _cachedIntrinsicContentSize = nil
        
        super.invalidateIntrinsicContentSize()
    }
    
    private func computeIntrinsicContentSize() -> CGSize? {
        if let _cachedIntrinsicContentSize = _cachedIntrinsicContentSize {
            return _cachedIntrinsicContentSize
        }
        
        if let preferredMaximumLayoutWidth = preferredMaximumDimensions.width {
            self._cachedIntrinsicContentSize = sizeThatFits(
                CGSize(
                    width: preferredMaximumLayoutWidth,
                    height: AppKitOrUIKitView.layoutFittingCompressedSize.height
                )
                .clamped(to: preferredMaximumDimensions)
            )
        } else if !isScrollEnabled {
            self._cachedIntrinsicContentSize = .init(
                width: bounds.width,
                height: textHeight(forWidth: bounds.width)
            )
        } else {
            self._cachedIntrinsicContentSize = .init(
                width: UIView.noIntrinsicMetric,
                height: min(
                    preferredMaximumDimensions.height ?? contentSize.height,
                    contentSize.height
                )
            )
        }
        
        return self._cachedIntrinsicContentSize
    }
    
    private func adjustFontSizeToFitWidth() {
        guard !text.isEmpty && !bounds.size.equalTo(CGSize.zero) else {
            return
        }
        
        let textViewSize = frame.size;
        let fixedWidth = textViewSize.width;
        let expectSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if expectSize.height > textViewSize.height {
            while sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height > textViewSize.height {
                font = font!.withSize(font!.pointSize - 1)
            }
        } else {
            while sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height < textViewSize.height {
                font = font!.withSize(font!.pointSize + 1)
            }
        }
    }
}

// MARK: - Helpers -

fileprivate extension UITextView {
    func textHeight(forWidth width: CGFloat) -> CGFloat {
        let storage = NSTextStorage(attributedString: attributedText)
        let width = bounds.width - textContainerInset.horizontal
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        let manager = NSLayoutManager()
        
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)
        
        container.lineFragmentPadding = textContainer.lineFragmentPadding
        container.lineBreakMode = textContainer.lineBreakMode
        
        _ = manager.glyphRange(for: container)
        
        return ceil(manager.usedRect(for: container).height + textContainerInset.vertical)
    }
}

#endif
