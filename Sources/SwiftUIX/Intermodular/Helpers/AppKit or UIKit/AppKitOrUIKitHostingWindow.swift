//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
public protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow, NSWindowDelegate {
    @_spi(Internal)
    var syncedWindows: [_SwiftUIX_Weak<any AppKitOrUIKitHostingWindowProtocol>] { get set }

    var configuration: _AppKitOrUIKitHostingWindowConfiguration { get set }
    
    func show()
    
    @_spi(Internal)
    func refreshPosition()
    @_spi(Internal)
    func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>)
}
#else
public protocol AppKitOrUIKitHostingWindowProtocol: AppKitOrUIKitWindow {
    @_spi(Internal)
    var syncedWindows: [_SwiftUIX_Weak<any AppKitOrUIKitHostingWindowProtocol>] { get set }
    
    var configuration: _AppKitOrUIKitHostingWindowConfiguration { get set }
    
    func show()
    
    @_spi(Internal)
    func refreshPosition()
    @_spi(Internal)
    func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>)
}
#endif

@_spi(Internal)
extension AppKitOrUIKitHostingWindowProtocol {
    public var syncedWindows: [_SwiftUIX_Weak<any AppKitOrUIKitHostingWindowProtocol>] {
        get {
            fatalError("unimplemented")
        } set {
            fatalError("unimplemented")
        }
    }
    
    public func refreshPosition() {
        fatalError("unimplemented")
    }
    
    public func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>) {
        fatalError("unimplemented")
    }
}

public struct _AppKitOrUIKitHostingWindowConfiguration: Equatable {
    public var style: _WindowStyle = .default
    public var canBecomeKey: Bool?
    public var allowTouchesToPassThrough: Bool = false
    @_spi(Internal)
    public var windowPosition: _CoordinateSpaceRelative<CGPoint>?
    public var isTitleBarHidden: Bool?
    public var backgroundColor: Color?
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
public final class AppKitOrUIKitHostingWindow<Content: View>: AppKitOrUIKitWindow, AppKitOrUIKitHostingWindowProtocol {
    public typealias PreferredConfiguration = _AppKitOrUIKitHostingWindowConfiguration
    
    @_spi(Internal)
    public var syncedWindows: [_SwiftUIX_Weak<any AppKitOrUIKitHostingWindowProtocol>] = []
    
    weak var windowPresentationController: _WindowPresentationController<Content>?
    
    /// The window's preferred configuration.
    ///
    /// This is informed by SwiftUIX's window preference key values.
    public var configuration = PreferredConfiguration() {
        didSet {
            #if os(macOS)
            refreshPosition()
            #endif
            
            guard configuration != oldValue else {
                return
            }
            
            #if os(iOS)
            if oldValue.windowPosition == nil, configuration.windowPosition != nil {
                refreshPosition()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.refreshPosition()
                }
            }
            #elseif os(macOS)
            if oldValue.allowTouchesToPassThrough != configuration.allowTouchesToPassThrough {
                ignoresMouseEvents = oldValue.allowTouchesToPassThrough
            }
            #endif
            
            applyPreferredConfiguration()
        }
    }
    
    #if os(macOS)
    override public var canBecomeKey: Bool {
        configuration.canBecomeKey ?? super.canBecomeKey
    }
    
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
            
            refreshPosition()
        }
    }
    #endif
    
    public func applyPreferredConfiguration() {
        guard !_NSWindow_didWindowJustClose else {
            return
        }
        
        refreshPosition()
        
        #if os(iOS) || os(tvOS)
        if let backgroundColor = configuration.backgroundColor?.toAppKitOrUIKitColor() {
            self.backgroundColor = backgroundColor
        }
        #elseif os(macOS)
        if let backgroundColor = configuration.backgroundColor?.toAppKitOrUIKitColor() {
            _assignIfNotEqual(backgroundColor, to: \.backgroundColor)
        }
        
        if configuration.style != .plain {
            if self.backgroundColor == .clear {
                _assignIfNotEqual(false, to: \.isOpaque)
                _assignIfNotEqual(false, to: \.hasShadow)
            } else {
                _assignIfNotEqual(true, to: \.isOpaque)
                _assignIfNotEqual(true, to: \.hasShadow)
            }
        }
        
        if configuration.style == .default {
            if (configuration.isTitleBarHidden ?? false) {
                if styleMask.contains(.titled) {
                    styleMask.remove(.titled)
                }
            } else {
                if !styleMask.contains(.titled) {
                    styleMask.formUnion(.titled)
                }
            }
        }
        
        if configuration.style == .hiddenTitleBar {
            _assignIfNotEqual(true, to: \.isMovableByWindowBackground)
            _assignIfNotEqual(true, to: \.titlebarAppearsTransparent)
            _assignIfNotEqual(.hidden, to: \.titleVisibility)
            
            standardWindowButton(.miniaturizeButton)?.isHidden = true
            standardWindowButton(.closeButton)?.isHidden = true
            standardWindowButton(.zoomButton)?.isHidden = true
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
    public convenience init(
        rootView: Content,
        style: _WindowStyle
    ) {
        let contentViewController = CocoaHostingController(
            mainView: AppKitOrUIKitHostingWindowContent(
                windowBox: .init(nil),
                content: rootView
            )
        )
        
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
                self.configuration.style = style
                
                applyPreferredConfiguration()
            case .plain:
                self.init(
                    contentRect: .zero,
                    styleMask: [.borderless, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                
                self.contentViewController = contentViewController
                self.configuration.style = style
                
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
        }
        
        performSetUp()
        
        delegate = self
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, style: .default)
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
        if styleMask.contains(.titled) {
            title = ""
        }
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
        if let canBecomeKey = configuration.canBecomeKey {
            guard canBecomeKey else {
                return
            }
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
        if let canBecomeKey = configuration.canBecomeKey {
            guard canBecomeKey else {
                return
            }
        }
        
        super.makeKey()
    }
    
    override public func becomeKey() {
        if let canBecomeKey = configuration.canBecomeKey {
            guard canBecomeKey else {
                return
            }
        }
        
        super.becomeKey()
    }
    #endif
    
    // MARK: - API
    
    public func show() {
        #if os(macOS)
        rootHostingViewController.mainView.windowBox.wrappedValue = self
        contentWindowController = contentWindowController ?? NSWindowController(window: self)
        
        if configuration.windowPosition == nil {
            alphaValue = 0.0
            
            contentWindowController?.showWindow(self)
            
            DispatchQueue.main.async {
                self.applyPreferredConfiguration()
                self.alphaValue = 1.0
            }
        } else {
            contentWindowController?.showWindow(self)
            
            self.alphaValue = 1.0
        }
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
    
    @_spi(Internal)
    public func refreshPosition() {
        guard let windowPosition = configuration.windowPosition else {
            return
        }
        
        setPosition(windowPosition)
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

// MARK: - API

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
    /// Use the `windowPosition(x:y:)` modifier to place the center of a window at a specific coordinate in the screen using `offset`.
    public func windowPosition(
        _ offset: CGPoint?
    ) -> some View {
        preference(
            key: _SwiftUIX_WindowPreferenceKeys.Position.self,
            value: offset.map({ _CoordinateSpaceRelative<CGPoint>($0, in: .coordinateSpace(.global)) })
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
    
    public func windowPosition(
        _ point: _CoordinateSpaceRelative<CGPoint>
    ) -> some View {
        preference(
            key: _SwiftUIX_WindowPreferenceKeys.Position.self,
            value: point
        )
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
    
    final class Position: TakeLastPreferenceKey<_CoordinateSpaceRelative<CGPoint>> {
        
    }
    
    final class TitleBarIsHidden: TakeLastPreferenceKey<Bool> {
        
    }
    
    final class BackgroundColor: TakeLastPreferenceKey<Color> {
        
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
fileprivate struct AppKitOrUIKitHostingWindowContent<Content: View>: View {
    @ObservedObject var windowBox: _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>
    
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
                .animation(.none)
            }
        }
        .environment(\._windowProxy, WindowProxy(window: windowBox.wrappedValue))
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.AllowsTouchesToPassThrough.self) { allowTouchesToPassThrough in
            queueWindowUpdate {
                $0.configuration.allowTouchesToPassThrough = allowTouchesToPassThrough ?? false
            }
        }
        .onPreferenceChange(_SwiftUIX_WindowPreferenceKeys.Position.self) { windowPosition in
            guard let windowPosition else {
                return
            }
            
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
        ._onChange(of: windowBox.wrappedValue != nil) { isWindowNotNil in
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
        let windowBox: _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>
        
        var isPresented: Bool {
            (windowBox.wrappedValue?.isHidden ?? false) == true
        }
        
        init(windowBox: _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitHostingWindow<Content>>) {
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

#if os(iOS) || os(tvOS) || os(visionOS)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    @_spi(Internal)
    public func setPosition(
        _ position: _CoordinateSpaceRelative<CGPoint>
    ) {
        if configuration.windowPosition != position {
            configuration.windowPosition = position
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
    @_spi(Internal)
    public func setPosition(
        _ position: _CoordinateSpaceRelative<CGPoint>
    ) {
        // contentView?._SwiftUIX_setDebugBackgroundColor(NSColor.red)
        
        // This isn't a `guard` because we do not want to exit early. Even if the window position is the same, the actual desired position may have changed (window position can be relative).
        if configuration.windowPosition != position {
            configuration.windowPosition = position
        }
        
        guard let sourceWindow = windowPresentationController?._sourceAppKitOrUIKitWindow ?? position._sourceAppKitOrUIKitWindow ?? AppKitOrUIKitApplication.shared.windows.first else {
            assertionFailure()
            
            return
        }
        
        if var position = position[.coordinateSpace(.global)] {
            var rect = CGRect(
                origin: position,
                size: self.frame.size
            )
            
            rect.origin.y = sourceWindow.frame.height - position.y
            
            position = sourceWindow.convertToScreen(rect).origin
            
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

#endif
