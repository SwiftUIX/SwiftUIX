//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
@MainActor
public final class _WindowPresentationController<Content: View>: ObservableObject {
    public var content: Content {
        didSet {
            guard contentWindow != nil else {
                return
            }
            
            _setNeedsUpdate(immediately: true)
        }
    }
    
    weak var _sourceAppKitOrUIKitWindow: AppKitOrUIKitWindow?
    
    public let windowStyle: _WindowStyle
    
    private var _updateWorkItem: DispatchWorkItem?
    
    public func _setNeedsUpdate(immediately: Bool = false) {
        guard !immediately else {
            _updateWorkItem?.cancel()
            _updateWorkItem = nil
            
            self._update()
            
            return
        }
        
        _updateWorkItem?.cancel()
        _updateWorkItem = nil
        
        let item = DispatchWorkItem {
            self._update()
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
    
    var _externalIsVisibleBinding: Binding<Bool>?
    
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
    
    init(
        content: Content,
        windowStyle: _WindowStyle = .default,
        canBecomeKey: Bool,
        isVisible: Bool
    ) {
        self.content = content
        self.windowStyle = windowStyle
        self.canBecomeKey = canBecomeKey
        self.isVisible = isVisible
        
        DispatchQueue.asyncOnMainIfNecessary {
            self._update()
        }
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
        
    public func show() {
        isVisible = true
        
        _setNeedsUpdate(immediately: true)
    }
    
    public func hide() {
        isVisible = false
        
        _setNeedsUpdate(immediately: true)
    }
    
    func _update() {
        defer {
            _updateWorkItem = nil
        }
        
        if let contentWindow = contentWindow, contentWindow.isHidden == !isVisible {
            contentWindow.rootView = content

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
                style: windowStyle
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
            contentWindow.configuration.canBecomeKey = canBecomeKey
                        
            #if os(iOS)
            let userInterfaceStyle: UIUserInterfaceStyle = preferredColorScheme == .light ? .light : .dark
            
            if contentWindow.overrideUserInterfaceStyle != userInterfaceStyle {
                _assignIfNotEqual(userInterfaceStyle, to: &window.overrideUserInterfaceStyle)
                
                if let rootViewController = contentWindow.rootViewController {
                    _assignIfNotEqual(userInterfaceStyle, to: &rootViewController.overrideUserInterfaceStyle)
                }
            }
            #endif
            
            #if os(iOS) || os(tvOS)
            _assignIfNotEqual(UIWindow.Level(rawValue: window.windowLevel.rawValue + 1), to: &contentWindow.windowLevel)
            #endif
            
            contentWindow.show()
            
            if canBecomeKey == false {
                assert(!contentWindow.isKeyWindow)
            }
        } else {
            contentWindow?.hide()
            contentWindow = nil
        }
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

public enum _WindowStyle {
    case `default`
    case hiddenTitleBar
    case plain
    case titleBar

    @available(macOS 11.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    init(from windowStyle: any WindowStyle) {
        switch windowStyle {
            case is DefaultWindowStyle:
                self = .`default`
            case is HiddenTitleBarWindowStyle:
                self = .hiddenTitleBar
            case is TitleBarWindowStyle:
                self = .titleBar
            default:
                assertionFailure("unimplemented")
                
                self = .default
        }
    }
}

#endif
