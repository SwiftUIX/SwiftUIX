//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
public final class _WindowPresentationController<Content: View>: ObservableObject {
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
    
    public let windowStyle: _WindowStyle
    
    private var _content: ContentBacking {
        didSet {
            guard contentWindow != nil else {
                return
            }
            
            _setNeedsUpdate(immediately: true)
        }
    }
    
    weak var _sourceAppKitOrUIKitWindow: AppKitOrUIKitWindow?
    var _externalIsVisibleBinding: Binding<Bool>?
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
    
    @Published public var canBecomeKey: Bool {
        didSet {
            if contentWindow == nil || canBecomeKey != oldValue {
                _setNeedsUpdate()
            }
        }
    }
    
    @Published public var isVisible: Bool {
        didSet {
            if contentWindow == nil || isVisible != oldValue {
                _setNeedsUpdate()
            }
        }
    }
        
    @Published public var preferredColorScheme: ColorScheme? {
        didSet {
            if contentWindow == nil || preferredColorScheme != oldValue {
                _setNeedsUpdate()
            }
        }
    }
    
    @_spi(Internal)
    public var contentWindow: AppKitOrUIKitHostingWindow<Content>? {
        didSet {
            _bindVisibilityToContentWindow()
        }
    }
    
    public func setPosition(_ position: _CoordinateSpaceRelative<CGPoint>) {
        contentWindow?.setPosition(position)
#if os(macOS)
        contentWindow?.orderFront(nil)
#endif
    }
    
    init(
        content: ContentBacking,
        windowStyle: _WindowStyle = .default,
        canBecomeKey: Bool,
        isVisible: Bool
    ) {
        self._content = content
        self.windowStyle = windowStyle
        self.canBecomeKey = canBecomeKey
        self.isVisible = isVisible
        
        if isVisible, content.hostingController != nil {
            self._update()
            
            assert(contentWindow != nil)
        } else {
            DispatchQueue.main.async {
                self._update()
            }
        }
    }
    
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
            isVisible: true
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
    
    public func show() {
        isVisible = true
        
        _setNeedsUpdate(immediately: true)
    }
    
    public func hide() {
        isVisible = false
        
        _setNeedsUpdate(immediately: true)
    }
    
    private func _bindVisibilityToContentWindow() {
        contentWindow?.isVisibleBinding = Binding(
            get: { [weak self] in
                self?.isVisible ?? false
            },
            set: { [weak self] in
                self?.isVisible = $0
                self?._externalIsVisibleBinding?.wrappedValue = $0
            }
        )
    }
    
    private func _tearDown() {
        _updateWorkItem?.cancel()
        
        hide()
        
        _updateWorkItem?.cancel()
    }
    
    deinit {
        _tearDown()
    }
}

extension _WindowPresentationController {
    func _update() {
        defer {
            _updateWorkItem = nil
        }
        
        if let contentWindow = contentWindow, contentWindow.isHidden == !isVisible {
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
            guard let window = AppKitOrUIKitWindow._firstKeyInstance, let windowScene = window.windowScene else {
                return
            }
            #endif
            
            #if os(macOS)
            let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(
                rootView: content,
                style: windowStyle,
                contentViewController: _content.hostingController
            )
            #else
            let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(
                windowScene: windowScene,
                rootView: content
            )
            #endif
            
            contentWindow.windowPresentationController = self
            
            self.contentWindow = contentWindow
            
            contentWindow.rootView = content
            contentWindow._SwiftUIX_windowConfiguration.canBecomeKey = canBecomeKey
            
            #if os(iOS)
            let userInterfaceStyle: UIUserInterfaceStyle = preferredColorScheme == .light ? .light : .dark
            
            if contentWindow.overrideUserInterfaceStyle != userInterfaceStyle {
                window._assignIfNotEqual(userInterfaceStyle, to: \.overrideUserInterfaceStyle)
                
                if let rootViewController = contentWindow.rootViewController {
                    rootViewController._assignIfNotEqual(userInterfaceStyle, to: \.overrideUserInterfaceStyle)
                }
            }
            #endif
            
            #if os(iOS) || os(tvOS)
            contentWindow._assignIfNotEqual(UIWindow.Level(rawValue: window.windowLevel.rawValue + 1), to: \.windowLevel)
            #endif
            
            contentWindow._sizeWindowToNonZeroFitThenPerform { [weak self] in
                contentWindow.show()
                
                guard let `self` = self else {
                    return
                }
                
                if self.canBecomeKey == false {
                    assert(!contentWindow.isKeyWindow)
                }
            }
        } else {
            contentWindow?._SwiftUIX_dismiss()
            contentWindow = nil
        }
    }
}

// MARK: - Initializers

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
