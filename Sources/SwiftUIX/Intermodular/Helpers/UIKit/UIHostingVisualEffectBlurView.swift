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
    private var oldBlurStyle: UIBlurEffect.Style?
    private var oldVibrancyStyle: UIVibrancyEffectStyle?
    private var blurEffectAnimator: UIViewPropertyAnimator? = UIViewPropertyAnimator(duration: 1, curve: .linear)
        
    var rootView: Content {
        get {
            hostingController.rootView
        } set {
            hostingController.rootView = newValue
        }
    }
    
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
    
    var intensity: Double {
        didSet {
            DispatchQueue.asyncOnMainIfNecessary {
                if let animator = self.blurEffectAnimator {
                    guard animator.fractionComplete != CGFloat(self.intensity) else {
                        return
                    }
                    
                    animator.fractionComplete = CGFloat(self.intensity)
                }
            }
        }
    }
    
    init(
        blurStyle: UIBlurEffect.Style,
        vibrancyStyle: UIVibrancyEffectStyle?,
        rootView: Content,
        intensity: Double
    ) {
        self.blurStyle = blurStyle
        self.vibrancyStyle = vibrancyStyle
        self.intensity = intensity
        
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
        blurView.effect = nil
        vibrancyView.effect = nil
        
        blurEffectAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        
        blurEffectAnimator?.stopAnimation(true)
        
        let blurEffect = UIBlurEffect(style: blurStyle)
        
        blurEffectAnimator?.addAnimations {
            self.blurView.effect = blurEffect
        }
        
        if let vibrancyStyle = vibrancyStyle {
            vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
        } else {
            vibrancyView.effect = nil
        }
        
        hostingController.view.setNeedsDisplay()
    }
    
    deinit {
        blurEffectAnimator?.stopAnimation(true)
        blurEffectAnimator = nil
    }
}

#endif
