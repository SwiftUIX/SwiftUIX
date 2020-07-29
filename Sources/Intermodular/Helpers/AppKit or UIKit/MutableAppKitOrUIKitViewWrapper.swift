//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

public final class MutableAppKitOrUIKitViewWrapper<Base: UIView>: UIView {
    private var _base: Base?
    
    public var base: Base? {
        get {
            _base
        } set {
            _base?.removeFromSuperview()
            _base = newValue
            
            if let base = _base {
                base.translatesAutoresizingMaskIntoConstraints = false

                addSubview(base)
                
                NSLayoutConstraint.activate([
                    topAnchor.constraint(equalTo: base.topAnchor),
                    leadingAnchor.constraint(equalTo: base.leadingAnchor),
                    bottomAnchor.constraint(equalTo: base.bottomAnchor),
                    trailingAnchor.constraint(equalTo: base.trailingAnchor)
                ])
            }
            
            setNeedsLayout()
            layoutSubviews()
        }
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public convenience init(base: Base) {
        self.init()
        
        self.base = base
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#elseif os(macOS)

import AppKit
import SwiftUI

public final class MutableAppKitOrUIKitViewWrapper<Base: NSView>: NSView {
    private var _base: Base?
    
    public var base: Base? {
        get {
            _base
        } set {
            _base?.removeFromSuperview()
            _base = newValue
            
            if let base = _base {
                base.translatesAutoresizingMaskIntoConstraints = false
                
                addSubview(base)
                
                NSLayoutConstraint.activate([
                    topAnchor.constraint(equalTo: base.topAnchor),
                    leadingAnchor.constraint(equalTo: base.leadingAnchor),
                    bottomAnchor.constraint(equalTo: base.bottomAnchor),
                    trailingAnchor.constraint(equalTo: base.trailingAnchor)
                ])
            }
            
            layout()
        }
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public convenience init(base: Base) {
        self.init()
        
        self.base = base
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
