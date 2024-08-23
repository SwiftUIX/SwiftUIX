//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

@_documentation(visibility: internal)
public class _AnyWindowPresentationController: ObservableObject {
    init() {
        
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@_documentation(visibility: internal)
public final class _WindowPresentationController<Content: View>: _AnyWindowPresentationController {
    @_documentation(visibility: internal)
public enum ContentBacking {
        case view(Content)
        case hostingController(AppKitOrUIKitHostingWindow<Content>._ContentViewControllerType)
        
        var hostingController: AppKitOrUIKitHostingWindow<Content>._ContentViewControllerType? {
            guard case .hostingController(let result) = self else {
                return nil
            }

            return result
        }
    }
    
    @Published private var configuration: _AppKitOrUIKitHostingWindowConfiguration {
        didSet {
            if configuration != oldValue {
                _setNeedsUpdate()
            }
        }
    }
 
    public var windowStyle: _WindowStyle {
        configuration.style
    }
    
    private var _content: ContentBacking {
        didSet {
            guard _contentWindow != nil else {
                return
            }
            
            _setNeedsUpdate(immediately: true)
        }
    }
    
    weak var _sourceAppKitOrUIKitWindow: AppKitOrUIKitWindow?
    
    @Published
    package var _isVisible: Bool = false
    package var _externalIsVisibleBinding: Binding<Bool>?
    
    private var _updateWorkItem: DispatchWorkItem?

    public var content: Content {
        get {
            switch _content {
                case .view(let view):
                    return view
                case .hostingController(let hostingController):
                    return hostingController.mainView.content
            }
        } set {
            switch _content {
                case .view:
                    _content = .view(newValue)
                case .hostingController(let hostingController):
                    hostingController.mainView.content = newValue
            }
        }
    }
        
    public func _setNeedsUpdate(immediately: Bool = false) {
        guard !immediately else {
            _updateWorkItem?.cancel()
            _updateWorkItem = nil
            
            self._update()
            
            return
        }
        
        _updateWorkItem?.cancel()
        _updateWorkItem = nil
        
        let item = DispatchWorkItem { [weak self] in
            self?._update()
        }
        
        DispatchQueue.main.async(execute: item)
        
        _updateWorkItem = item
    }
    
    public var canBecomeKey: Bool {
        get {
            self.configuration.canBecomeKey ?? true
        } set {
            self.configuration.canBecomeKey = newValue
        }
    }
    
    public var isVisible: Bool {
        get {
            _isVisible
        } set {
            guard _isVisible != newValue else {
                return
            }
            
            _isVisible = newValue
            
            if let _contentWindow {
                if _contentWindow.isVisible != _isVisible {
                    _setNeedsUpdate()
                }
            } else {
                _setNeedsUpdate()
            }
        }
    }
        
    @_spi(Internal)
    public var _contentWindow: AppKitOrUIKitHostingWindow<Content>? {
        didSet {
            if _contentWindow !== oldValue {
                oldValue?._SwiftUIX_dismiss()
            }
            
            _bindVisibilityToContentWindow()
        }
    }

    public var preferredColorScheme: ColorScheme? {
        get {
            self.configuration.preferredColorScheme
        } set {
            self.configuration.preferredColorScheme = newValue
        }
    }
            
    public var contentWindow: AppKitOrUIKitHostingWindow<Content>{
        self._contentWindow ?? _makeContentWindowUnconditionally()
    }
    
    public func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>?) {
        if let _contentWindow {
            _contentWindow.setPosition(position)
        } else {
            configuration.windowPosition = position
        }
    }
    
    init(
        content: ContentBacking,
        windowStyle: _WindowStyle = .default,
        canBecomeKey: Bool,
        isVisible: Bool
    ) {
        self.configuration = .init(style: windowStyle, canBecomeKey: canBecomeKey)
        self._content = content
        self._isVisible = isVisible
        
        super.init()

        if isVisible {
            if content.hostingController != nil {
                self._update()
                
                assert(_contentWindow != nil)
            }
        } else {
            Task.detached(priority: .userInitiated) { @MainActor in
                self._update()
            }
        }
    }
        
    @MainActor
    public func show() {
        isVisible = true
        
        _setNeedsUpdate(immediately: true)
    }
    
    @MainActor
    public func hide() {
        isVisible = false
        
        _setNeedsUpdate(immediately: true)
    }
    
    private func _bindVisibilityToContentWindow() {
        _contentWindow?.isVisibleBinding = Binding(
            get: { [weak self] in
                self?.isVisible ?? false
            },
            set: { [weak self] in
                self?.isVisible = $0
                self?._externalIsVisibleBinding?.wrappedValue = $0
            }
        )
    }
    
    deinit {
        _updateWorkItem?.cancel()
        
        if let window = _contentWindow {
            Task { @MainActor in
                window.windowPresentationController = nil
                window._SwiftUIX_dismiss()
            }
        }
    }
}

extension _WindowPresentationController {
    func _update() {
        defer {
            _updateWorkItem = nil
        }
        
        if let contentWindow = _contentWindow, contentWindow.isHidden == !isVisible {
            contentWindow.rootView = content
            
            #if os(macOS)
            if contentWindow._SwiftUIX_windowConfiguration.canBecomeKey == true, !contentWindow.isKeyWindow {
                if let appKeyWindow = AppKitOrUIKitApplication.shared.firstKeyWindow, appKeyWindow !== contentWindow {
                    contentWindow._assignIfNotEqual(NSWindow.Level(rawValue: appKeyWindow.level.rawValue + 1), to: \.level)
                }
            }
            #endif
            
            return
        }
        
        if isVisible {
            #if !os(macOS)
            guard let keyAppWindow = AppKitOrUIKitWindow._firstKeyInstance else {
                return
            }
            #endif

            let contentWindow = self.contentWindow
                                    
            #if os(iOS)
            let userInterfaceStyle: UIUserInterfaceStyle = preferredColorScheme == .light ? .light : .dark
            
            if contentWindow.overrideUserInterfaceStyle != userInterfaceStyle {
                contentWindow._assignIfNotEqual(userInterfaceStyle, to: \.overrideUserInterfaceStyle)
                
                if let rootViewController = contentWindow.rootViewController {
                    rootViewController._assignIfNotEqual(userInterfaceStyle, to: \.overrideUserInterfaceStyle)
                }
            }
            #endif
            
            #if os(iOS) || os(tvOS)
            contentWindow._assignIfNotEqual(UIWindow.Level(rawValue: keyAppWindow.windowLevel.rawValue + 1), to: \.windowLevel)
            #endif
            
            contentWindow._sizeWindowToNonZeroFitThenPerform { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                contentWindow._SwiftUIX_windowConfiguration.mergeInPlace(with: self.configuration)
                
                contentWindow.show()
                
                if self.canBecomeKey == false {
                    assert(!contentWindow.isKeyWindow)
                }
            }
        } else {
            guard let window = self._contentWindow, window.isVisible == true else {
                return
            }
            
            window._SwiftUIX_dismiss()
            
            self._contentWindow = nil
        }
    }
    
    private func _makeContentWindowUnconditionally() -> AppKitOrUIKitHostingWindow<Content> {
        #if os(macOS)
        let contentWindow = AppKitOrUIKitHostingWindow(
            rootView: content,
            style: windowStyle,
            contentViewController: _content.hostingController
        )
        #else
        let contentWindow = AppKitOrUIKitHostingWindow(
            windowScene: AppKitOrUIKitWindow._firstKeyInstance!.windowScene!,
            rootView: content
        )
        #endif
        
        contentWindow.windowPresentationController = self
        
        self._contentWindow = contentWindow
        
        contentWindow.rootView = content
        contentWindow._SwiftUIX_windowConfiguration.canBecomeKey = canBecomeKey
        
        return contentWindow
    }
    
    package func _showWasCalledOnWindow() {
        if let isVisibleBinding = self._externalIsVisibleBinding {
            if !isVisibleBinding.wrappedValue {
                isVisibleBinding.wrappedValue = true
            }
        }

        self._isVisible = true
    }
    
    package func _windowDidJustClose() {
        if let isVisibleBinding = self._externalIsVisibleBinding {
            if !isVisibleBinding.wrappedValue {
                isVisibleBinding.wrappedValue = false
            }
        }
        
        self._isVisible = false
    }
}

// MARK: - Initializers

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension _WindowPresentationController {
    convenience init(
        content: Content,
        windowStyle: _WindowStyle = .default,
        canBecomeKey: Bool,
        isVisible: Bool
    ) {
        self.init(
            content: .view(content),
            windowStyle: windowStyle,
            canBecomeKey: canBecomeKey,
            isVisible: isVisible
        )
    }
    
    public convenience init(
        content: Content
    ) {
        self.init(
            content: content,
            windowStyle: .default,
            canBecomeKey: true,
            isVisible: false
        )
    }
    
    public convenience init(
        @ViewBuilder content: () -> Content
    ) {
        self.init(content: content())
    }
    
    public convenience init(
        style: _WindowStyle,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            content: content(),
            windowStyle: style,
            canBecomeKey: true,
            isVisible: false
        )
    }
    
    public convenience init(
        style: _WindowStyle,
        visible: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            content: content(),
            windowStyle: style,
            canBecomeKey: true,
            isVisible: visible
        )
    }
}

#if os(macOS)
extension _WindowPresentationController {
    public convenience init(
        content: Content,
        _windowStyle: _WindowStyle
    ) {
        self.init(
            content: content,
            windowStyle: _windowStyle,
            canBecomeKey: true,
            isVisible: false
        )
    }
    
    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public convenience init<Style: WindowStyle>(
        content: Content,
        windowStyle: Style
    ) {
        self.init(
            content: content,
            windowStyle: .init(from: windowStyle),
            canBecomeKey: true,
            isVisible: false
        )
    }
    
    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @_disfavoredOverload
    public convenience init<_Content: View, Style: WindowStyle>(
        content: _Content,
        windowStyle: Style
    ) where Content == AnyView {
        self.init(
            content: content.eraseToAnyView(),
            windowStyle: .init(from: windowStyle),
            canBecomeKey: true,
            isVisible: false
        )
    }
}
#endif

// MARK: - Auxiliary

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitHostingWindow {
    fileprivate func _sizeWindowToNonZeroFitThenPerform(
        perform action: @escaping () -> Void
    ) {
        guard let contentView = _SwiftUIX_contentView else {
            return
        }
        
        if contentView.frame.size.isAreaZero {
            #if os(macOS)
            if let contentWindowController = contentView._SwiftUIX_nearestWindow?.contentViewController as? AppKitOrUIKitHostingControllerProtocol {
                if #available(macOS 13.0, *) {
                    contentWindowController.sizingOptions = [.minSize, .intrinsicContentSize, .maxSize]
                }
            }
            
            contentView._SwiftUIX_setNeedsLayout()
            contentView._SwiftUIX_layoutIfNeeded()
            #endif
            
            DispatchQueue.main.async {
                if contentView.frame.size.isAreaZero {
                    print("Failed to size window for presentation.")
                    
                    contentView._SwiftUIX_setNeedsLayout()
                    contentView._SwiftUIX_layoutIfNeeded()
                }
                
                action()
            }
        } else {
            action()
        }
    }
}

#endif

#if os(macOS)
extension NSDocument {
    public func addWindowController<T>(
        _ controller: _WindowPresentationController<T>
    ) {
        guard let windowController = controller._sourceAppKitOrUIKitWindow?.windowController else {
            return
        }
        
        self.addWindowController(windowController)
    }
}
#endif
