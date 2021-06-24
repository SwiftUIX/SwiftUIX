//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

open class UIHostingVisualEffectBlurView<Content: View>: UIView {
    private let vibrancyView = UIVisualEffectView()
    private let blurView = UIVisualEffectView()
    private let hostingController: UIHostingController<Content>
    
    var blurStyle: UIBlurEffect.Style {
        didSet {
            // TODO: Implement
        }
    }
    
    var vibrancyStyle: UIVibrancyEffectStyle? {
        didSet {
            // TODO: Implement
        }
    }
    
    var vibrancyTintColor: UIColor? {
        didSet {
            vibrancyView.tintColor = vibrancyTintColor
        }
    }

    public var rootView: Content {
        get {
            hostingController.rootView
        } set {
            hostingController.rootView = newValue
            
            let blurEffect = UIBlurEffect(style: blurStyle)
            
            blurView.effect = blurEffect
            
            if let vibrancyStyle = vibrancyStyle {
                vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
            } else {
                vibrancyView.effect = nil
            }
            
            hostingController.view.setNeedsDisplay()
        }
    }
    
    public init(
        blurStyle: UIBlurEffect.Style,
        vibrancyStyle: UIVibrancyEffectStyle?,
        rootView: Content
    ) {
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
        
        hostingController = UIHostingController(rootView: rootView)
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.view.backgroundColor = nil
        
        vibrancyView.contentView.addSubview(hostingController.view)
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        blurView.contentView.addSubview(vibrancyView)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.init(frame: .zero)
        
        addSubview(blurView)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
