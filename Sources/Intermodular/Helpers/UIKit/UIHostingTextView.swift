//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public class UIHostingTextView<Label: View>: UITextView {
    open var preferredMaximumLayoutWidth: CGFloat? {
        didSet {
            if preferredMaximumLayoutWidth != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    open var adjustsFontSizeToFitWidth: Bool = false {
        didSet {
            if adjustsFontSizeToFitWidth != oldValue {
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
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }
}

// MARK: - Helpers -

fileprivate extension UITextView {
    func textHeightForWidth(_ width: CGFloat) -> CGFloat {
        sizeThatFits(.init(width: width, height: .greatestFiniteMagnitude)).height
    }
}

#endif
