//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _SwiftUIX
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
public protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow, NSWindowDelegate {
    var _SwiftUIX_hostingPopoverPreferences: _AppKitOrUIKitHostingPopoverPreferences { get set }
    var _SwiftUIX_windowConfiguration: _AppKitOrUIKitHostingWindowConfiguration { get set }
    
    func _SwiftUIX_present()
    func _SwiftUIX_waitForShow() async
    func _SwiftUIX_dismiss()

    func show()
    func hide()

    func refreshPosition()
    func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>?)
    
    func bringToFront()
    func moveToBack()
}
#else
public protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow {
    typealias PreferredConfiguration = _AppKitOrUIKitHostingWindowConfiguration

    var _SwiftUIX_windowConfiguration: _AppKitOrUIKitHostingWindowConfiguration { get set }
    
    func _SwiftUIX_present()
    func _SwiftUIX_waitForShow() async
    func _SwiftUIX_dismiss()

    func show()
    func hide()

    func refreshPosition()
    func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>?)
    
    func bringToFront()
    func moveToBack()
}
#endif

extension AppKitOrUIKitHostingWindowProtocol {
    public func refreshPosition() {
        fatalError("unimplemented")
    }
}

#if !os(macOS)
extension AppKitOrUIKitHostingWindowProtocol {
    public func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>) {
        fatalError("unimplemented")
    }
}
#endif

@_documentation(visibility: internal)
public struct _AppKitOrUIKitHostingWindowConfiguration: Hashable, Sendable {
    public var style: _WindowStyle
    public var canBecomeKey: Bool?
    public var allowTouchesToPassThrough: Bool?
    public var windowPosition: _CoordinateSpaceRelative<CGPoint>?
    public var isTitleBarHidden: Bool?
    public var backgroundColor: Color?
    public var preferredColorScheme: ColorScheme?

    public init(
        style: _WindowStyle = .default,
        canBecomeKey: Bool? = nil,
        allowTouchesToPassThrough: Bool? = nil,
        windowPosition: _CoordinateSpaceRelative<CGPoint>? = nil,
        isTitleBarHidden: Bool? = nil,
        backgroundColor: Color? = nil,
        preferredColorScheme: ColorScheme? = nil
    ) {
        self.style = style
        self.canBecomeKey = canBecomeKey
        self.allowTouchesToPassThrough = allowTouchesToPassThrough
        self.windowPosition = windowPosition
        self.isTitleBarHidden = isTitleBarHidden
        self.backgroundColor = backgroundColor
        self.preferredColorScheme = preferredColorScheme
    }
    
    public mutating func mergeInPlace(with other: Self) {
        self.canBecomeKey = other.canBecomeKey ?? self.canBecomeKey
        self.allowTouchesToPassThrough = other.allowTouchesToPassThrough ?? self.allowTouchesToPassThrough
        self.windowPosition = other.windowPosition ?? self.windowPosition
        self.isTitleBarHidden = other.isTitleBarHidden ?? self.isTitleBarHidden
        self.backgroundColor = other.backgroundColor ?? self.backgroundColor
        self.preferredColorScheme = other.preferredColorScheme ?? self.preferredColorScheme
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@_documentation(visibility: internal)
open class AppKitOrUIKitHostingWindow<Content: View>: AppKitOrUIKitWindow, AppKitOrUIKitHostingWindowProtocol {
    public typealias _ContentViewControllerType = CocoaHostingController<_AppKitOrUIKitHostingWindowContent<Content>>
    
    private var _NSWindow_didWindowJustClose: Bool = false

    /// The presentation controller associated with this window.
    weak var windowPresentationController: _WindowPresentationController<Content>?
    /// A copy of the root view for when the `contentViewController` is deinitialized (for macOS windows).
    fileprivate var copyOfRootView: Content?
    var isVisibleBinding: Binding<Bool> = .constant(true)
    #if os(macOS)
    private var _contentWindowController: NSWindowController?
    #endif
    
    public var _SwiftUIX_hostingPopoverPreferences: _AppKitOrUIKitHostingPopoverPreferences = nil

    /// The window's preferred configuration.
    ///
    /// This is informed by SwiftUIX's window preference key values.
    public var _SwiftUIX_windowConfiguration = _AppKitOrUIKitHostingWindowConfiguration() {
        didSet {
            #if os(macOS)
            refreshPosition()
            #endif
            
            guard _SwiftUIX_windowConfiguration != oldValue else {
                return
            }
            
            #if os(iOS)
            if oldValue.windowPosition == nil, _SwiftUIX_windowConfiguration.windowPosition != nil {
                refreshPosition()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.refreshPosition()
                }
            }
            #elseif os(macOS)
            if oldValue.allowTouchesToPassThrough != _SwiftUIX_windowConfiguration.allowTouchesToPassThrough {
                if let allowTouchesToPassThrough = _SwiftUIX_windowConfiguration.allowTouchesToPassThrough {
                    ignoresMouseEvents = allowTouchesToPassThrough
                }
            }
            #endif
            
            applyPreferredConfiguration()
        }
    }
    
    #if os(macOS)
    override open var alphaValue: CGFloat {
        get {
            super.alphaValue
        } set {
            guard newValue != super.alphaValue else {
                return
            }
            
            super.alphaValue = newValue
            
            if newValue == 0.0 {
                if isKeyWindow {
                    resignKey()
                }
                
                if _SwiftUIX_isFirstResponder {
                    resignFirstResponder()
                }
            }
        }
    }
    
    override public var canBecomeMain: Bool {
        guard !alphaValue.isZero, !isHidden else {
            return false
        }
        
        return super.canBecomeKey
    }
    
    override public var canBecomeKey: Bool {
        guard !alphaValue.isZero, !isHidden else {
            return false
        }

        return _SwiftUIX_windowConfiguration.canBecomeKey ?? super.canBecomeKey
    }
    #endif
        
    private var _disableBecomingKeyWindow: Bool {
        if let canBecomeKey = _SwiftUIX_windowConfiguration.canBecomeKey {
            guard canBecomeKey else {
                return true
            }
        }
        
        if alphaValue == 0.0 && isHidden {
            return true
        }
        
        return false
    }

    public var _rootHostingViewController: CocoaHostingController<_AppKitOrUIKitHostingWindowContent<Content>>! {
        get {
            #if os(macOS)
            if let contentViewController = contentViewController as? CocoaHostingController<_AppKitOrUIKitHostingWindowContent<Content>> {
                return contentViewController
            } else {
                guard let rootView: Content = copyOfRootView else {
                    return nil
                }
                
                let contentViewController = CocoaHostingController(
                    mainView: _AppKitOrUIKitHostingWindowContent(
                        window: self,
                        popover: nil,
                        content: rootView
                    )
                )
                                
                self.copyOfRootView = nil
                
                self.contentViewController = contentViewController
                
                return contentViewController
            }
            #else
            return rootViewController as? CocoaHostingController<_AppKitOrUIKitHostingWindowContent<Content>>
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
                    
                    if let newValue {
                        contentViewController = newValue
                    } else {
                        contentViewController = nil
                    }
                }
                #else
                fatalError()
                #endif
            }
        }
    }
        
    public var rootView: Content {
        get {
            _rootHostingViewController.rootView.content.content
        } set {
            _rootHostingViewController.rootView.content.content = newValue
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
            
            refreshPosition()
        }
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public var isVisible: Bool {
        !isHidden && windowLevel >= .normal && alpha > 0
    }
    
    override public var isHidden: Bool {
        didSet {
            _rootHostingViewController.rootView.content.isPresented = !isHidden
        }
    }
    #elseif os(macOS)
    override open var isVisible: Bool {
        get {
            super.isVisible
        }
    }
    #endif
    
    public func applyPreferredConfiguration() {
        guard !_NSWindow_didWindowJustClose else {
            return
        }
        
        refreshPosition()
        
        #if os(iOS) || os(tvOS)
        if let backgroundColor = _SwiftUIX_windowConfiguration.backgroundColor?.toAppKitOrUIKitColor() {
            self.backgroundColor = backgroundColor
        }
        #elseif os(macOS)
        if let backgroundColor = _SwiftUIX_windowConfiguration.backgroundColor?.toAppKitOrUIKitColor() {
            _assignIfNotEqual(backgroundColor, to: \.backgroundColor)
        }
        
        if _SwiftUIX_windowConfiguration.style != .plain {
            if self.backgroundColor == .clear {
                _assignIfNotEqual(false, to: \.isOpaque)
                _assignIfNotEqual(false, to: \.hasShadow)
            } else {
                _assignIfNotEqual(true, to: \.isOpaque)
                _assignIfNotEqual(true, to: \.hasShadow)
            }
        }
        
        if _SwiftUIX_windowConfiguration.style == .default {
            if (_SwiftUIX_windowConfiguration.isTitleBarHidden ?? false) {
                if styleMask.contains(.titled) {
                    styleMask.remove(.titled)
                }
            } else {
                if !styleMask.contains(.titled) {
                    styleMask.formUnion(.titled)
                }
            }
        }
        
        if _SwiftUIX_windowConfiguration.style == .hiddenTitleBar {
            _assignIfNotEqual(true, to: \.isMovableByWindowBackground)
            _assignIfNotEqual(true, to: \.titlebarAppearsTransparent)
            _assignIfNotEqual(.hidden, to: \.titleVisibility)
            
            standardWindowButton(.miniaturizeButton)?.isHidden = true
            standardWindowButton(.closeButton)?.isHidden = true
            standardWindowButton(.zoomButton)?.isHidden = true
        }
        #endif
    }
        
    #if os(macOS)
    public convenience init(
        rootView: Content,
        style: _WindowStyle,
        contentViewController: _ContentViewControllerType? = nil
    ) {
        let contentViewController = contentViewController ?? _ContentViewControllerType(
            mainView: _AppKitOrUIKitHostingWindowContent(
                window: nil,
                popover: nil,
                content: rootView
            )
        )
        
        assert(contentViewController.mainView._window == nil)
                
        contentViewController._configureSizingOptions(for: AppKitOrUIKitWindow.self)
        
        switch style {
            case .`default`:
                self.init(contentViewController: contentViewController)
            case .hiddenTitleBar:
                let styleMask: NSWindow.StyleMask = [.titled, .closable, .resizable, .miniaturizable]
                
                self.init(
                    contentRect: .zero,
                    styleMask: styleMask,
                    backing: .buffered,
                    defer: false
                )
                
                contentViewController.title = nil
                
                self.contentViewController = contentViewController
                self._SwiftUIX_windowConfiguration.style = style
                
                applyPreferredConfiguration()
            case .plain:
                self.init(
                    contentRect: .zero,
                    styleMask: [.borderless, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                
                self.contentViewController = contentViewController
                self._SwiftUIX_windowConfiguration.style = style
                
                if #available(macOS 13.0, *) {
                    collectionBehavior.insert(.auxiliary)
                }
                
                level = .floating
                backgroundColor = NSColor.clear
                isOpaque = false
                styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
                styleMask.remove(NSWindow.StyleMask.titled)
                hasShadow = false
            case .titleBar:
                self.init(contentViewController: contentViewController)
                
                self._SwiftUIX_windowConfiguration.style = style
            case ._transparent:
                self.init(contentViewController: contentViewController)
                
                self._SwiftUIX_windowConfiguration.style = style
        }
        
        Task.detached { @MainActor in
            contentViewController.mainView._window = self
        }
        
        contentViewController.mainView.initialized = true
        
        if self.contentViewController == nil {
            self.contentViewController = contentViewController
        }
        
        assert(self._SwiftUIX_windowConfiguration.style == style)
        
        performSetUp()
        
        delegate = self
    }
    
    public convenience init(
        rootView: Content
    ) {
        self.init(rootView: rootView, style: .default)
    }
    #else
    public init(
        windowScene: UIWindowScene,
        rootView: Content
    ) {
        super.init(windowScene: windowScene)
        
        let contentViewController = CocoaHostingController(
            mainView: _AppKitOrUIKitHostingWindowContent(
                window: self,
                popover: nil,
                content: rootView
            )
        )
        
        self.rootViewController = contentViewController
        
        contentViewController.view.backgroundColor = .clear
        contentViewController.mainView.initialized = true
        
        performSetUp()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif
    
    private func performSetUp() {
        #if os(iOS) || os(tvOS)
        canResizeToFitContent = true
        #elseif os(macOS)
        switch _SwiftUIX_windowConfiguration.style {
            case .default, .hiddenTitleBar, .plain, .titleBar: do {
                if styleMask.contains(.titled) {
                    title = ""
                }
            }
            case ._transparent:
                styleMask = [.borderless, .fullSizeContentView]
                collectionBehavior = [.fullScreenPrimary]
                level = .floating
                titleVisibility = .hidden
                titlebarAppearsTransparent = true
                isMovable = true
                isMovableByWindowBackground = true
                ignoresMouseEvents = false

                standardWindowButton(.closeButton)?.isHidden = true
                standardWindowButton(.miniaturizeButton)?.isHidden = true
                standardWindowButton(.zoomButton)?.isHidden = true
                
                hasShadow = false
                isOpaque = false
                backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0)
                
                zoom(self)
        }
        #endif
    }
    
    #if os(iOS)
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard (_SwiftUIX_windowConfiguration.allowTouchesToPassThrough ?? false) else {
            return super.hitTest(point, with: event)
        }
        
        let result = super.hitTest(point, with: event)
        
        if result == rootViewController?.view {
            return nil
        }
        
        return result
    }
    
    override public func makeKey() {
        guard !_disableBecomingKeyWindow else {
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
    
    override public func makeKey() {
        if let canBecomeKey = _SwiftUIX_windowConfiguration.canBecomeKey {
            guard canBecomeKey else {
                return
            }
        }
        
        super.makeKey()
    }
            
    override public func makeKeyAndOrderFront(_ sender: Any?) {
        if _disableBecomingKeyWindow {
            super.orderFront(nil)
        } else {
            super.makeKeyAndOrderFront(nil)
        }
    }
    
    override public func becomeKey() {
        guard !_disableBecomingKeyWindow else {
            return
        }
        
        super.becomeKey()
    }
    #endif
    
    // MARK: - API
    
    public func show() {
        if let controller = windowPresentationController {
            controller._showWasCalledOnWindow()
        }

        _SwiftUIX_present()
    }

    public func hide() {
        _SwiftUIX_dismiss()
    }

    public func _SwiftUIX_present() {
        #if os(macOS)
        _rootHostingViewController.mainView._window = self
       
        let contentWindowController = self._contentWindowController ?? NSWindowController(window: self)
        
        if self.contentViewController?.view.frame.size == Screen.bounds.size {
            self.styleMask.insert(.fullSizeContentView)
        }
        
        self._contentWindowController = contentWindowController
        
        self.isHidden = false

        assert(contentWindowController.window !== nil)
        
        if _SwiftUIX_windowConfiguration.windowPosition == nil {
            contentWindowController.showWindow(self)
            
            DispatchQueue.main.async {
                assert(self._rootHostingViewController.mainView._window != nil)
                
                self.applyPreferredConfiguration()
                
                contentWindowController.window!.center()
            }
        } else {
            self.applyPreferredConfiguration()

            contentWindowController.showWindow(self)
            
            DispatchQueue.main.async {
                self.applyPreferredConfiguration()
            }
        }
        #else
        isHidden = false
        isUserInteractionEnabled = true
        
        makeKeyAndVisible()
        
        rootViewController?.view.setNeedsDisplay()
        #endif
    }
        
    public func _SwiftUIX_dismiss() {
        #if os(macOS)
        _rootHostingViewController = nil
        
        if let contentWindowController = self._contentWindowController {
            contentWindowController.close()
        } else {
            close()
        }
        #endif
                
        _SwiftUIX_tearDownForWindowDidClose()
    }
        
    #if os(macOS)
    override open func close() {
        _SwiftUIX_tearDownForWindowDidClose()

        super.close()
    }
    #else
    @objc open func close() {
        _SwiftUIX_dismiss()
    }
    #endif
    
    #if os(macOS)
    override open func constrainFrameRect(
        _ frameRect: NSRect,
        to screen: NSScreen?
    ) -> NSRect {
        if _SwiftUIX_windowConfiguration.style == .plain {
            return frameRect
        } else {
            return super.constrainFrameRect(frameRect, to: nil)
        }
    }
    #endif
    
    // MARK: - NSWindowDelegate
        
    public func windowWillClose(_ notification: Notification) {
        _NSWindow_didWindowJustClose = true
        
        #if os(macOS)
        self._contentWindowController?.window = nil
        self._contentWindowController = nil
        #endif

        DispatchQueue.main.async {
            self.isVisibleBinding.wrappedValue = false
        }
    }
    
    // MARK: - Other
    
    private func _SwiftUIX_tearDownForWindowDidClose() {
        #if os(macOS)
        if self._contentWindowController != nil {
            self._contentWindowController?.window = nil
            self._contentWindowController = nil
        }
        
        if let rootHostingViewController = self._rootHostingViewController, let popover = rootHostingViewController._SwiftUIX_parentNSPopover as? _AnyAppKitOrUIKitHostingPopover, popover.isDetached {
            popover._SwiftUIX_detachedWindowDidClose()
        }
        #else
        _assignIfNotEqual(false, to: \.isHidden)
        _assignIfNotEqual(false, to: \.isUserInteractionEnabled)
        _assignIfNotEqual(nil, to: \.windowScene)
        #endif
        
        if isVisibleBinding.wrappedValue {
            isVisibleBinding.wrappedValue = false
        }
        
        windowPresentationController?._windowDidJustClose()
    }
}

extension AppKitOrUIKitHostingWindow {
    public func refreshPosition() {
        guard let windowPosition = _SwiftUIX_windowConfiguration.windowPosition else {
            return
        }
        
        setPosition(windowPosition)
    }
}

// MARK: - Initializers
 
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public convenience init(
        windowScene: UIWindowScene,
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(windowScene: windowScene, rootView: rootView())
    }
}
#elseif os(macOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public convenience init(
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(rootView: rootView())
    }
}
#endif

// MARK: - Supplementary

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension View {
    /// Allows touches in the active window overlay to pass through if possible.
    public func windowAllowsTouchesToPassThrough(
        _ allowed: Bool
    ) -> some View {
        preference(
            key: _SwiftUIX_WindowPreferenceKeys.AllowsTouchesToPassThrough.self,
            value: allowed
        )
    }
        
    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using an `x` and `y` offset.
    public func windowPosition(
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        windowPosition(CGPoint(x: x, y: y))
    }
    
    @_disfavoredOverload
    public func windowPosition(
        _ point: _CoordinateSpaceRelative<CGPoint>?
    ) -> some View {
        preference(
            key: _SwiftUIX_WindowPreferenceKeys.Position.self,
            value: point
        )
    }
    
    /// Positions the center of this window at the specified coordinates in the screen's coordinate space.
    ///
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using `offset`.
    public func windowPosition(
        _ offset: CGPoint?
    ) -> some View {
        preference(
            key: _SwiftUIX_WindowPreferenceKeys.Position.self,
            value: offset.map({ _CoordinateSpaceRelative<CGPoint>($0, in: .coordinateSpace(.global)) })
        )
    }
    
    /// Sets the background color of the presented window.
    public func windowOverlayBackgroundColor(_ backgroundColor: Color) -> some View {
        preference(key: _SwiftUIX_WindowPreferenceKeys.BackgroundColor.self, value: backgroundColor)
    }
}

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || os(visionOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public func setPosition(
        _ position: _CoordinateSpaceRelative<CGPoint>?
    ) {
        guard let position else {
            return
        }
        
        if _SwiftUIX_windowConfiguration.windowPosition != position {
            _SwiftUIX_windowConfiguration.windowPosition = position
        }

        if let position = position[.coordinateSpace(.global)] {
            let originX: CGFloat = position.x - (self.frame.size.width / 2)
            let originY: CGFloat = position.y - (self.frame.size.height / 2)
            
            self.frame.origin = .init(
                x: originX,
                y: originY
            )
        } else {
            assertionFailure("unimplemented")
        }
    }
}
#elseif os(macOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    public func setPosition(
        _ position: _CoordinateSpaceRelative<CGPoint>?
    ) {
        guard let position else {
            return
        }

        // contentView?._SwiftUIX_setDebugBackgroundColor(NSColor.red)
        
        // This isn't a `guard` because we do not want to exit early. Even if the window position is the same, the actual desired position may have changed (window position can be relative).
        if _SwiftUIX_windowConfiguration.windowPosition != position {
            _SwiftUIX_windowConfiguration.windowPosition = position
        }
        
        let sourceWindow: AppKitOrUIKitWindow? = windowPresentationController?._sourceAppKitOrUIKitWindow ?? position._sourceAppKitOrUIKitWindow
        
        if var position = position[.coordinateSpace(.global)] {
            var rect = CGRect(
                origin: position,
                size: self.frame.size
            )
            
            if let sourceWindow {
                rect.origin.y = sourceWindow.frame.height - position.y
                
                position = sourceWindow.convertToScreen(rect).origin
            }
                        
            let origin = CGPoint(
                x: position.x - (self.frame.size.width / 2),
                y: position.y - (self.frame.size.height / 2)
            )
            
            setFrameOrigin(origin)
        } else if let (point, position) = position.first(where: { $0._cocoaScreen != nil }) {
            let screen = point._cocoaScreen!
            
            let origin = CGPoint(
                x: position.x,
                y: screen.height - (position.y + self.frame.size.height)
            )

            setFrameOrigin(origin)
        } else if let (_, _) = position.first(where: { $0._cocoaScreen != nil }) {
            assertionFailure("unimplemented")
        } else {
            assertionFailure("unimplemented")
        }
    }
}
#endif

#if os(macOS)
extension NSWindow {
    static var didBecomeVisibleNotification: Notification.Name {
        Notification.Name("com.vmanot.SwiftUIX.AppKitOrUIKitHostingWindow.didBecomeVisibleNotification")
    }
}
#endif

extension AppKitOrUIKitHostingWindow {
    public func _SwiftUIX_waitForShow() async {
        guard let _rootHostingViewController, _rootHostingViewController._hostingViewStateFlags.contains(.hasAppearedAndIsCurrentlyVisible) else {
            return
        }
        
        await withUnsafeContinuation { continuation in
            NotificationCenter.default.addObserver(forName: AppKitOrUIKitWindow.didBecomeVisibleNotification, object: self, queue: .main) { _ in
                Task { @MainActor in
                    NotificationCenter.default.removeObserver(self, name: AppKitOrUIKitWindow.didBecomeVisibleNotification, object: nil)
                    
                    continuation.resume()
                }
            }
        }
    }
}

#endif
