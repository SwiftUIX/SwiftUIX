//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

#if os(macOS)
protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow, NSWindowDelegate {
    
}
#else
protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow {
    
}
#endif

public final class AppKitOrUIKitHostingWindow<Content: View>: AppKitOrUIKitWindow, AppKitOrUIKitHostingWindowProtocol {
    public struct PreferredConfiguration {
        public var canBecomeKey: Bool = true
        public var allowTouchesToPassThrough: Bool = false
        public var windowPosition: CGPoint?
        public var isTitleBarHidden: Bool?
        public var backgroundColor: Color?
    }
        
    /// The window's preferred configuration.
    ///
    /// This is informed by SwiftUIX's window preference key values.
    public var configuration = PreferredConfiguration() {
        didSet {
            #if os(iOS)
            if oldValue.windowPosition == nil, configuration.windowPosition != nil {
                setWindowOrigin()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.setWindowOrigin()
                }
            }
            #else
            setWindowOrigin()
            #endif
            
            applyPreferredConfiguration()
        }
    }
    
    #if os(macOS)
    var contentWindowController: NSWindowController?
    #endif
    
    /// A copy of the root view for when the `contentViewController` is deinitialized (for macOS windows).
    fileprivate var copyOfRootView: Content?

    fileprivate var rootHostingViewController: CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>! {
        get {
            #if os(macOS)
            if let contentViewController = contentViewController as? CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>> {
                return contentViewController
            } else {
                let contentViewController = CocoaHostingController(
                    mainView: AppKitOrUIKitHostingWindowContent(
                        windowBox: .init(self),
                        content: copyOfRootView!
                    )
                )

                copyOfRootView = nil
                
                self.contentViewController = contentViewController
                
                return contentViewController
            }
            #else
            return rootViewController as? CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>
            #endif
        } set {
            if let newValue = newValue {
                #if os(macOS)
                contentViewController = newValue
                #else
                rootViewController = newValue
                #endif
            } else {
                #if os(macOS)
                if contentViewController != nil {
                    copyOfRootView = rootView
                    
                    contentViewController = nil
                }
                #else
                fatalError()
                #endif
            }
        }
    }
    
    var isVisibleBinding: Binding<Bool> = .constant(true)
    
    public var rootView: Content {
        get {
            rootHostingViewController.rootView.content.content
        } set {
            rootHostingViewController.rootView.content.content = newValue
        }
    }
    
    #if os(iOS)
    override public var frame: CGRect {
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
    
    public func applyPreferredConfiguration() {
        guard !_NSWindow_didWindowJustClose else {
            return
        }
        
        setWindowOrigin()
        
        #if os(iOS) || os(tvOS)
        backgroundColor = configuration.backgroundColor?.toAppKitOrUIKitColor()
        #elseif os(macOS)
        backgroundColor = configuration.backgroundColor?.toAppKitOrUIKitColor()

        if configuration.backgroundColor == .clear {
            hasShadow = false
            isOpaque = false
        } else {
            hasShadow = true
            isOpaque = true
        }
        
        if (configuration.isTitleBarHidden ?? false) {
            styleMask.remove(.titled)
        } else {
            styleMask.formUnion(.titled)
        }
        #endif
    }

    #if os(iOS)
    override public var isHidden: Bool {
        didSet {
            rootHostingViewController.rootView.content.isPresented = !isHidden
        }
    }
    #endif
    
    #if os(macOS)
    public convenience init(rootView: Content) {
        let contentViewController = CocoaHostingController(
            mainView: AppKitOrUIKitHostingWindowContent(
                windowBox: .init(nil),
                content: rootView
            )
        )

        self.init(contentViewController: contentViewController)
                    
        delegate = self
    }
    #else
    public init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(mainView: AppKitOrUIKitHostingWindowContent(windowBox: .init(self), content: rootView))
        rootViewController!.view.backgroundColor = .clear
        
        performSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif

    private func performSetUp() {
        #if os(iOS) || os(tvOS)
        canResizeToFitContent = true
        #elseif os(macOS)
        title = ""
        #endif
    }
    
    #if os(iOS)
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard configuration.allowTouchesToPassThrough else {
            return super.hitTest(point, with: event)
        }
        
        let result = super.hitTest(point, with: event)
        
        if result == rootViewController?.view {
            return nil
        }
        
        return result
    }
    
    override public func makeKey() {
        guard configuration.canBecomeKey else {
            return
        }
        
        super.makeKey()
    }
    #elseif os(macOS)
    override public func layoutIfNeeded() {
        // Needed to fix a crash.
        // https://developer.apple.com/forums/thread/114579
        if _NSWindow_didWindowJustClose {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self._NSWindow_didWindowJustClose = false
            }
            
            return
        }
        
        super.layoutIfNeeded()
    }
    #endif
    
    // MARK: - API
    
    public func show() {
        #if os(macOS)
        rootHostingViewController.mainView.windowBox.wrappedValue = self
        contentWindowController = contentWindowController ?? NSWindowController(window: self)
        contentWindowController?.showWindow(self)
        #else
        isHidden = false
        isUserInteractionEnabled = true
        
        makeKeyAndVisible()
        
        rootViewController?.view.setNeedsDisplay()
        #endif
    }
    
    public func hide() {
        #if os(macOS)
        rootHostingViewController = nil

        if let contentWindowController = contentWindowController {
            contentWindowController.close()
        } else {
            close()
        }

        tearDownWindow()
        #else
        isHidden = true
        isUserInteractionEnabled = false
        windowScene = nil
        #endif
    }
    
    // MARK: - Internal
    
    private func setWindowOrigin() {
        guard let windowPosition = configuration.windowPosition else {
            return
        }
        
        let originX = (windowPosition.x - (self.frame.size.width / 2))
        let originY = (windowPosition.y - (self.frame.size.height / 2))
        
        #if os(iOS)
        self.frame.origin = .init(
            x: originX,
            y: originY
        )
        #elseif os(macOS)
        setFrameOrigin(.init(x: originX, y: -originY))
        #endif
    }
    
    // MARK: - NSWindowDelegate
    
    var _NSWindow_didWindowJustClose: Bool = false
    
    public func windowWillClose(_ notification: Notification) {
        _NSWindow_didWindowJustClose = true

        tearDownWindow()
        
        DispatchQueue.main.async {
            self.isVisibleBinding.wrappedValue = false
        }
    }
    
    private func tearDownWindow() {
        #if os(macOS)
        contentWindowController?.window = nil
        contentWindowController = nil
        #endif
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitHostingWindow {
    public convenience init(
        windowScene: UIWindowScene,
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(windowScene: windowScene, rootView: rootView())
    }
}
#elseif os(macOS)
extension AppKitOrUIKitHostingWindow {
    public convenience init(
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(rootView: rootView())
    }
}
#endif

// MARK: - API

extension View {
    /// Allows touches in the active window overlay to pass through if possible.
    @available(macOS, unavailable)
    public func windowAllowsTouchesToPassThrough(_ allowed: Bool) -> some View {
        preference(key: _SwiftUIX_WindowPreferenceKeys.AllowsTouchesToPassThrough.self, value: allowed)
    }
    
    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using `offset`.
    public func windowPosition(_ offset: CGPoint) -> some View {
        preference(key: _SwiftUIX_WindowPreferenceKeys.Position.self, value: offset)
    }
    
    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using an `x` and `y` offset.
    public func windowPosition(x: CGFloat, y: CGFloat) -> some View {
        windowPosition(.init(x: x, y: y))
    }
    
    /// Sets the background color of the presented window.
    public func windowOverlayBackgroundColor(_ backgroundColor: Color) -> some View {
        preference(key: _SwiftUIX_WindowPreferenceKeys.BackgroundColor.self, value: backgroundColor)
    }
}

// MARK: - Auxiliary

enum _SwiftUIX_WindowPreferenceKeys {
    final class AllowsTouchesToPassThrough: TakeLastPreferenceKey<Bool> {
        
    }
    
    final class Position: TakeLastPreferenceKey<CGPoint> {
        
    }
    
    final class TitleBarIsHidden: TakeLastPreferenceKey<Bool> {
        
    }
    
    final class BackgroundColor: TakeLastPreferenceKey<Color> {
        
    }
}

fileprivate struct AppKitOrUIKitHostingWindowContent<Content: View>: View {
    @ObservedObject var windowBox: ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>
    
    var content: Content
    var isPresented: Bool = false
    
    @State var queuedWindowUpdates: [(AppKitOrUIKitHostingWindow<Content>) -> Void] = []
    
    private var presentationManager: _PresentationManager {
        _PresentationManager(windowBox: windowBox)
    }
    
    public var body: some View {
        PassthroughView {
            if windowBox.wrappedValue != nil {
                LazyAppearView {
                    content
                }
            }
        }
        .environment(\._windowProxy, WindowProxy(window: windowBox.wrappedValue))
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.AllowsTouchesToPassThrough.self) { allowTouchesToPassThrough in
            queueWindowUpdate {
                $0.configuration.allowTouchesToPassThrough = allowTouchesToPassThrough ?? false
            }
        }
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.Position.self) { windowPosition in
            queueWindowUpdate {
                $0.configuration.windowPosition = windowPosition
            }
        }
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.TitleBarIsHidden.self) { isTitleBarHidden in
            queueWindowUpdate {
                $0.configuration.isTitleBarHidden = isTitleBarHidden
            }
        }
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.BackgroundColor.self) { backgroundColor in
            queueWindowUpdate {
                $0.configuration.backgroundColor = backgroundColor
            }
        }
        .environment(\.presentationManager, presentationManager)
        .id(isPresented)
        .onChange(of: windowBox.wrappedValue != nil) { isWindowNotNil in
            if isWindowNotNil {
                queuedWindowUpdates.forEach({ $0(windowBox.wrappedValue!) })
                queuedWindowUpdates = []
            }
        }
        .onChangeOfFrame { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                windowBox.wrappedValue?.applyPreferredConfiguration()
            }
        }
        .id(windowBox.wrappedValue != nil)
    }
    
    func queueWindowUpdate(_ update: @escaping (AppKitOrUIKitHostingWindow<Content>) -> Void) {
        if let window = windowBox.wrappedValue {
            update(window)
        } else {
            queuedWindowUpdates.append(update)
        }
    }
    
    struct _PresentationManager: PresentationManager {
        let windowBox: ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>
        
        var isPresented: Bool {
            (windowBox.wrappedValue?.isHidden ?? false) == true
        }

        init(windowBox: ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>) {
            self.windowBox = windowBox
        }
                
        func dismiss() {
            #if os(macOS)
            windowBox.wrappedValue?.close()
            #else
            windowBox.wrappedValue?.isHidden = true
            #endif
            
            windowBox.wrappedValue?.isVisibleBinding.wrappedValue = false
        }
    }
}

#endif
