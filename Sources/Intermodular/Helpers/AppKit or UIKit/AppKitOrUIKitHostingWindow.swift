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
    
    var isKeyAndVisible: Binding<Bool> = .constant(true)
    
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
            .onPreferenceChange(WindowPositionPreferenceKey.self) { value in
                if let window = self.window, let value = value {
                    if window.frame.origin != value {
                        #if os(macOS)
                        window.setFrameOrigin(value)
                        #else
                        UIView.animate(withDuration: 0.2) {
                            window.frame.origin = value
                        }
                        #endif
                    }
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
