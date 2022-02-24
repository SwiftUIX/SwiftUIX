//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class AppKitOrUIKitHostingWindow<Content: View>: AppKitOrUIKitWindow {
    fileprivate var rootHostingViewController: CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>> {
        #if os(macOS)
        return contentViewController as! CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>
        #else
        return rootViewController as! CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>
        #endif
    }
    
    var rootView: Content {
        get {
            rootHostingViewController.rootView.content.content
        } set {
            rootHostingViewController.rootView.content.content = newValue
        }
    }
    
    #if os(iOS)
    override var frame: CGRect {
        get {
            super.frame
        } set {
            guard newValue != frame else {
                return
            }
            
            super.frame = newValue
            
            setWindowOrigin()
        }
    }
    #endif
             
    var isKeyAndVisible: Binding<Bool> = .constant(true)

    var allowTouchesToPassThrough: Bool = false

    var windowPosition: CGPoint? {
        didSet {
            #if os(iOS)
            if oldValue == nil {
                setWindowOrigin()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.setWindowOrigin()
                }
            }
            #else
            setWindowOrigin()
            #endif
        }
    }

    #if os(iOS)
    override var isHidden: Bool {
        didSet {
            rootHostingViewController.rootView.content.isPresented = !isHidden
        }
    }
    #endif
    
    #if os(macOS)
    convenience init(rootView: Content) {
        let contentViewController = CocoaHostingController(mainView: AppKitOrUIKitHostingWindowContent(window: nil, content: rootView))
        
        self.init(contentViewController: contentViewController)
        
        contentViewController.mainView.window = self
    }
    #else
    init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(mainView: AppKitOrUIKitHostingWindowContent(window: self, content: rootView))
        rootViewController!.view.backgroundColor = .clear
    }
    
    convenience init(
        windowScene: UIWindowScene,
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(windowScene: windowScene, rootView: rootView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif

    #if os(iOS)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard allowTouchesToPassThrough else {
            return super.hitTest(point, with: event)
        }

        let result = super.hitTest(point, with: event)

        if result == rootViewController?.view {
            return nil
        }

        return result
    }
    #endif

    private func setWindowOrigin() {
        guard let windowPosition = windowPosition else {
            return
        }

        let originX = (windowPosition.x - (self.frame.size.width / 2))
        let originY = (windowPosition.y - (self.frame.size.height / 2))
        
        print(originX, originY)
        #if os(iOS)
        self.frame.origin = .init(
            x: originX,
            y: originY
        )
        #elseif os(macOS)
        setFrameOrigin(.init(x: originX, y: originY))
        #endif
    }
}

// MARK: - API -

extension View {
    /// Allows touches in the active window overlay to pass through if possible.
    @available(macOS, unavailable)
    public func windowAllowsTouchesToPassThrough(_ allowed: Bool) -> some View {
        preference(key: WindowAllowsTouchesToPassThrough.self, value: allowed)
    }

    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using `offset`.
    public func windowPosition(_ offset: CGPoint) -> some View {
        preference(key: WindowPositionPreferenceKey.self, value: offset)
    }
    
    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using an `x` and `y` offset.
    public func windowPosition(x: CGFloat, y: CGFloat) -> some View {
        windowPosition(.init(x: x, y: y))
    }
}

// MARK: - Auxiliary Implementation -

final class WindowAllowsTouchesToPassThrough: TakeLastPreferenceKey<Bool> {

}

final class WindowPositionPreferenceKey: TakeLastPreferenceKey<CGPoint> {
    
}

fileprivate struct AppKitOrUIKitHostingWindowContent<Content: View>: View {
    weak var window: AppKitOrUIKitHostingWindow<Content>?
    
    var content: Content
    var isPresented: Bool = false
    
    private var presentationManager: _PresentationManager {
        _PresentationManager(window: window)
    }
    
    public var body: some View {
        content
            .onPreferenceChange(WindowAllowsTouchesToPassThrough.self) { allowTouchesToPassThrough in
                window?.allowTouchesToPassThrough = (allowTouchesToPassThrough ?? false)
            }
            .onPreferenceChange(WindowPositionPreferenceKey.self) { windowPosition in
                window?.windowPosition = windowPosition
            }
            .environment(\.presentationManager, presentationManager)
            .id(isPresented)
    }
    
    struct _PresentationManager: PresentationManager {
        var window: AppKitOrUIKitHostingWindow<Content>?
        
        init(window: AppKitOrUIKitHostingWindow<Content>?) {
            self.window = window
        }
        
        var isPresented: Bool {
            window?.isHidden == false
        }
        
        func dismiss() {
            #if os(macOS)
            window?.close()
            #else
            window?.isHidden = true
            #endif
            
            window?.isKeyAndVisible.wrappedValue = false
        }
    }
}

#endif
