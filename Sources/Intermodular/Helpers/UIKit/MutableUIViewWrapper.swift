//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

public final class MutableUIViewWrapper<Content: UIView>: UIView {
    public var content: Content? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let content = content {
                
                addSubview(content)
                
                NSLayoutConstraint.activate([
                    topAnchor.constraint(equalTo: content.topAnchor),
                    leftAnchor.constraint(equalTo: content.leftAnchor),
                    bottomAnchor.constraint(equalTo: content.bottomAnchor),
                    rightAnchor.constraint(equalTo: content.rightAnchor)
                ])
            }
            
            setNeedsLayout()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
