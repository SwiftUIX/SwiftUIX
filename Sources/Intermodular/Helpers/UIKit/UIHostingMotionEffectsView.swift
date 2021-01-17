#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit
import SwiftUI

/// Wrapper that applies a motion effect to an underlying hosting controller, 
/// whose view will a `SwiftUI.View` (the `rootView` passed in at init time).
open class UIHostingMotionEffectsView<Content: View>: UIView {
    private let _motionEffectGroup: UIMotionEffectGroup
    private let _hostingController: UIHostingController<Content>
    
    /// Inits a new `UIHostingMotionEffectsView`.
    /// 
    /// - Parameters:
    ///   - magnitude: the maximum translation to use for the effect.
    ///   - rootView: the `View` the effect will apply to.
    public init(
        magnitude: CGFloat,
        rootView: Content
    ) {
        self._motionEffectGroup = Self.makeMotionEffectGroup(magnitude: magnitude)
        
        _hostingController = UIHostingController(rootView: rootView)
        _hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _hostingController.view.backgroundColor = nil
        
        super.init(frame: .zero)
        
        self.rootView = rootView
        
        addSubview(_hostingController.view)
        self.setNeedsDisplay()
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /// No-op init required by the compiler.
    /// 
    /// - Parameter coder: no-op
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The root view to apply the effect to.
    public var rootView: Content {
        get {
            _hostingController.rootView
        } set {
            _hostingController.rootView = newValue
            if _hostingController.view.motionEffects.isEmpty {
                _hostingController.view.addMotionEffect(_motionEffectGroup)
            }
            _hostingController.view.setNeedsDisplay()
        }
    }
    
    /// Creates a `UIMotionEffectGroup` to apply to a `View`.
    /// 
    /// - Parameter magnitude: the maximum translation to use for the effect.
    /// - Returns: a `UIMotionEffectGroup`.
    private static func makeMotionEffectGroup(magnitude: CGFloat = 30) -> UIMotionEffectGroup {
        let xMotion: UIInterpolatingMotionEffect = {
            let min = CGFloat(-magnitude)
            let max = CGFloat(magnitude)
            let xMotionSetting = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
            xMotionSetting.maximumRelativeValue = max
            xMotionSetting.minimumRelativeValue = min
            return xMotionSetting
        }()
        
        let yMotion: UIInterpolatingMotionEffect = {
            let min = CGFloat(-magnitude)
            let max = CGFloat(magnitude)
            let xMotionSetting = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
            xMotionSetting.maximumRelativeValue = max
            xMotionSetting.minimumRelativeValue = min
            return xMotionSetting
        }()
        
        let motionEffectGroupSetting = UIMotionEffectGroup()
        motionEffectGroupSetting.motionEffects = [xMotion,yMotion]
        return motionEffectGroupSetting
    }
}

#endif
