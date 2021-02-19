//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol UIHostingWindowProtocol: UIWindow {
    
}

open class UIHostingWindow<Content: View>: UIWindow, UIHostingWindowProtocol {
    public var rootHostingViewController: CocoaHostingController<UIHostingWindowContent<Content>> {
        rootViewController as! CocoaHostingController<UIHostingWindowContent<Content>>
    }
    
    public var rootView: Content {
        get {
            rootHostingViewController.rootView.content.content
        } set {
            rootHostingViewController.rootView.content.content = newValue
        }
    }
    
    public init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(mainView: UIHostingWindowContent(window: self, content: rootView))
        rootViewController!.view.backgroundColor = .clear
    }
    
    public convenience init(
        windowScene: UIWindowScene,
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(windowScene: windowScene, rootView: rootView())
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - API -

extension View {
    /// Positions the top-leading corner of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the top-leading corner of a window at a specific coordinate in the screen using `offset`.
    public func windowPosition(_ offset: CGPoint) -> some View {
        preference(key: WindowPositionPreferenceKey.self, value: offset)
    }
    
    /// Positions the top-leading corner of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the top-leading corner of a window at a specific coordinate in the screen using an `x` and `y` offset.
    public func windowPosition(x: CGFloat, y: CGFloat) -> some View {
        windowPosition(.init(x: x, y: y))
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
final class WindowPositionPreferenceKey: TakeLastPreferenceKey<CGPoint> {
    
}

public struct UIHostingWindowContent<Content: View>: View {
    @usableFromInline
    weak private(set) var window: UIWindow?
    
    @usableFromInline
    fileprivate(set) var content: Content
    
    @inlinable
    public var body: some View {
        content.onPreferenceChange(WindowPositionPreferenceKey.self) { value in
            if let window = self.window, let value = value {
                if window.frame.origin != value {
                    UIView.animate(withDuration: 0.2) {
                        window.frame.origin = value
                    }
                }
            }
        }
        .environment(\.presentationManager, _PresentationManager(window: window))
    }
    
    @usableFromInline
    struct _PresentationManager: PresentationManager {
        @usableFromInline
        let window: UIWindow?
        
        @usableFromInline
        init(window: UIWindow?) {
            self.window = window
        }
        
        @usableFromInline
        var isPresented: Bool {
            window?.isHidden == false
        }
        
        @usableFromInline
        func dismiss() {
            window?.isHidden = true
        }
    }
}

#endif
