//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UIPageViewController {
    var isPanGestureEnabled: Bool {
        get {
            gestureRecognizers.compactMap({ $0 as? UIPanGestureRecognizer }).first?.isEnabled ?? true
        } set {
            gestureRecognizers.compactMap({ $0 as? UIPanGestureRecognizer }).first?.isEnabled = newValue
        }
    }
    
    var isEdgePanGestureEnabled: Bool {
        get {
            #if os(tvOS)
            return false
            #else
            return gestureRecognizers.first(where: { $0 is UIScreenEdgePanGestureRecognizer })?.isEnabled ?? true
            #endif
        } set {
            #if !os(tvOS)
            return gestureRecognizers.filter({ $0 is UIScreenEdgePanGestureRecognizer }).forEach({ $0.isEnabled = newValue })
            #endif
        }
    }
    
    var isTapGestureEnabled: Bool {
        get {
            gestureRecognizers.first(where: { $0 is UITapGestureRecognizer })?.isEnabled ?? true
        } set {
            gestureRecognizers.filter({ $0 is UITapGestureRecognizer }).forEach({ $0.isEnabled = newValue })
        }
    }
    
    var isScrollEnabled: Bool {
        get {
            view.subviews.compactMap({ $0 as? UIScrollView }).first?.isScrollEnabled ?? true
        } set {
            view.subviews.compactMap({ $0 as? UIScrollView }).first?.isScrollEnabled = newValue
        }
    }
    
    var pageControl: UIPageControl? {
        view._SwiftUIX_findSubview(ofKind: UIPageControl.self)
    }
}

#endif
