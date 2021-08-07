//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

class UIHostingVisualEffectBlurView<Content: View>: UIView {
    private let vibrancyView = UIVisualEffectView()
    private let blurView = UIVisualEffectView()
    private let hostingController: UIHostingController<Content>
    
    override var tintColor: UIColor? {
        didSet {
            blurView.tintColor = tintColor
        }
    }
    
    var rootView: Content {
        get {
            hostingController.rootView
        } set {
            hostingController.rootView = newValue
        }
    }
    
    var oldBlurStyle: UIBlurEffect.Style?
    var oldVibrancyStyle: UIVibrancyEffectStyle?

    var blurStyle: UIBlurEffect.Style {
        didSet {
            guard blurStyle != oldValue else {
                return
            }
            
            updateBlurAndVibrancyEffect()
        }
    }
    
    var vibrancyStyle: UIVibrancyEffectStyle? {
        didSet {
            guard vibrancyStyle != oldValue else {
                return
            }
            
            updateBlurAndVibrancyEffect()
        }
    }
    
    init(
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
        
        updateBlurAndVibrancyEffect()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateBlurAndVibrancyEffect() {
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

#endif
