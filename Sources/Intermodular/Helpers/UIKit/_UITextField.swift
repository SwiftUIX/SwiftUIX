//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public final class _UITextField: UITextField {
    var kerning: CGFloat? {
        didSet {
            updateTextAttributes()
        }
    }
    
    var onDeleteBackward: () -> Void = { }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func editingChanged() {
        updateTextAttributes()
    }
    
    override public func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward()
    }
    
    func updateTextAttributes() {
        let attributedText: NSMutableAttributedString
        
        if let text = self.attributedText {
            attributedText = .init(attributedString: text)
        } else if let text = text {
            attributedText = .init(string: text)
        } else {
            attributedText = .init(string: "")
        }
        
        let fullRange = NSRange(location: 0, length: attributedText.string.count)
        
        if let kern = kerning ?? defaultTextAttributes[.kern] {
            attributedText.addAttribute(.kern, value: kern, range: fullRange)
        }
        
        if let font = font {
            attributedText.addAttribute(.font, value: font, range: fullRange)
        }
        
        if let textColor = textColor {
            attributedText.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        }
        
        self.attributedText = attributedText
    }
}

#endif
