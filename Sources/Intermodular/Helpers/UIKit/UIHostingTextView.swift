//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

final class UIHostingTextView<Label: View>: UITextView {
    var _isSwiftUIRuntimeUpdateActive: Bool = false
    var _isSwiftUIRuntimeDismantled: Bool = false
    
    var configuration: TextView<Label>._Configuration
    
    private var _cachedIntrinsicContentSize: CGSize?
    private var lastBounds: CGSize = .zero
    
    override var attributedText: NSAttributedString! {
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
    
    var numberOfLinesDisplayed: Int {
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
    
    var preferredMaximumDimensions: OptionalDimensions = nil {
        didSet {
            guard preferredMaximumDimensions != oldValue else {
                return
            }
            
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
    
    override var intrinsicContentSize: CGSize {
        computeIntrinsicContentSize() ?? super.intrinsicContentSize
    }
    
    required init(configuration: TextView<Label>._Configuration) {
        self.configuration = configuration
        
        super.init(frame: .zero, textContainer: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func invalidateIntrinsicContentSize() {
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
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        defer {
            if !_isSwiftUIRuntimeUpdateActive && !_isSwiftUIRuntimeDismantled {
                if configuration.isFocused?.wrappedValue != isFirstResponder {
                    configuration.isFocused?.wrappedValue = isFirstResponder
                }
            }
        }
        
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        defer {
            if !_isSwiftUIRuntimeUpdateActive && !_isSwiftUIRuntimeDismantled  {
                if configuration.isFocused?.wrappedValue != isFirstResponder {
                    configuration.isFocused?.wrappedValue = isFirstResponder
                }
            }
        }
        
        return super.resignFirstResponder()
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        configuration.onDeleteBackward()
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
