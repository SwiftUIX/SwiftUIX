//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class AppKitOrUIKitHostingWindow<Content: View>: AppKitOrUIKitWindow {
    fileprivate var rootHostingViewController: CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>> {
        #if os(macOS)
        return contentViewController as! CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>
        #else
        return rootViewController as! CocoaHostingController<AppKitOrUIKitHostingWindowContent<Content>>
        #endif
    }
    
    public var rootView: Content {
        get {
            rootHostingViewController.rootView.content.content
        } set {
            rootHostingViewController.rootView.content.content = newValue
        }
    }
    
    #if os(iOS)
    open override var frame: CGRect {
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
    override public var isHidden: Bool {
        didSet {
            rootHostingViewController.rootView.content.isPresented = !isHidden
        }
    }
    #endif
    
    #if os(macOS)
    public convenience init(rootView: Content) {
        let contentViewController = CocoaHostingController(mainView: AppKitOrUIKitHostingWindowContent(window: nil, content: rootView))
        
        self.init(contentViewController: contentViewController)
        
        contentViewController.mainView.window = self
    }
    #else
    public init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(mainView: AppKitOrUIKitHostingWindowContent(window: self, content: rootView))
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

@usableFromInline
final class WindowPositionPreferenceKey: TakeLastPreferenceKey<CGPoint> {
    
}

fileprivate struct AppKitOrUIKitHostingWindowContent<Content: View>: View {
    @usableFromInline
    weak var window: AppKitOrUIKitHostingWindow<Content>?
    
    @usableFromInline
    var content: Content
    
    @usableFromInline
    var isPresented: Bool = false
    
    private var presentationManager: _PresentationManager {
        _PresentationManager(window: window)
    }
    
    @inlinable
    public var body: some View {
        content
            .onPreferenceChange(WindowPositionPreferenceKey.self) { windowPosition in
                if let window = self.window {
                    window.windowPosition = windowPosition
                }
            }
            .environment(\.presentationManager, presentationManager)
            .id(isPresented)
    }
    
    @usableFromInline
    struct _PresentationManager: PresentationManager {
        @usableFromInline
        var window: AppKitOrUIKitHostingWindow<Content>?
        
        @usableFromInline
        init(window: AppKitOrUIKitHostingWindow<Content>?) {
            self.window = window
        }
        
        @usableFromInline
        var isPresented: Bool {
            window?.isHidden == false
        }
        
        @usableFromInline
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
