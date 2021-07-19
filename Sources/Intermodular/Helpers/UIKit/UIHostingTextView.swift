//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public class UIHostingTextView<Label: View>: UITextView {
    private var lastBounds: CGSize = .zero
    
    public var adjustsFontSizeToFitWidth: Bool = false {
        didSet {
            guard adjustsFontSizeToFitWidth != oldValue else {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public var preferredMaximumLayoutWidth: CGFloat? {
        didSet {
            let desiredContentHuggingPriority = preferredMaximumLayoutWidth == nil
                ? AppKitOrUIKitLayoutPriority.defaultLow
                : AppKitOrUIKitLayoutPriority.defaultHigh
            
            if contentHuggingPriority(for: .horizontal) != desiredContentHuggingPriority {
                setContentHuggingPriority(
                    desiredContentHuggingPriority,
                    for: .horizontal
                )
            }
            
            if let oldValue = oldValue, preferredMaximumLayoutWidth != oldValue {
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
        super.invalidateIntrinsicContentSize()
    }
    
    private func computeIntrinsicContentSize() -> CGSize? {
        var _intrinsicContentSize: CGSize?
        
        if let preferredMaximumLayoutWidth = preferredMaximumLayoutWidth {
            _intrinsicContentSize = sizeThatFits(
                CGSize(
                    width: preferredMaximumLayoutWidth,
                    height: AppKitOrUIKitView.layoutFittingCompressedSize.height
                )
            )
        } else if !isScrollEnabled {
            _intrinsicContentSize = .init(width: bounds.width, height: textHeight(forWidth: bounds.width))
        }

        return _intrinsicContentSize
    }
    
    public func adjustFontSizeToFitWidth() {
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
