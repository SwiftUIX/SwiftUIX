//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public class UIHostingTextView<Label: View>: UITextView {
    private var lastBounds: CGSize = .zero
    
    open var adjustsFontSizeToFitWidth: Bool = false {
        didSet {
            if adjustsFontSizeToFitWidth != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    open var preferredMaximumLayoutWidth: CGFloat? {
        didSet {
            if preferredMaximumLayoutWidth != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        if let preferredMaximumLayoutWidth = preferredMaximumLayoutWidth {
            return .init(width: min(bounds.width, preferredMaximumLayoutWidth), height: textHeightForWidth(preferredMaximumLayoutWidth))
        } else if !isScrollEnabled {
            return .init(width: bounds.width, height: textHeightForWidth(bounds.width))
        } else {
            return super.intrinsicContentSize
        }
    }
    
    override open var isScrollEnabled: Bool {
        didSet {
            guard isScrollEnabled != oldValue else {
                return
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
                
        if lastBounds != bounds.size {
            invalidateIntrinsicContentSize()
            
            lastBounds = bounds.size
        }
    }
    
    open func adjustFontSizeToFitWidth() {
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
    func textHeightForWidth(_ width: CGFloat) -> CGFloat {
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
