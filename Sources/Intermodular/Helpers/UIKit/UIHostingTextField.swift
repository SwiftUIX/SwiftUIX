//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public final class UIHostingTextField: UITextField {

    public typealias Rect = ((_ bounds: CGRect, _ original: CGRect) -> CGRect)

    public var onDeleteBackward: () -> Void = {}

    public var textRect: Rect?
    public var editingRect: Rect?
    public var clearButtonRect: Rect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func deleteBackward() {
        super.deleteBackward()
        
        onDeleteBackward()
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.textRect(forBounds: bounds)
        return textRect?(bounds, original) ?? original
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.editingRect(forBounds: bounds)
        return editingRect?(bounds, original) ?? original
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.clearButtonRect(forBounds: bounds)
        return clearButtonRect?(bounds, original) ?? original
    }
}

#endif
