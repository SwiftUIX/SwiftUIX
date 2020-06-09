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
            rootHostingViewController.rootViewContent.content
        } set {
            rootHostingViewController.rootViewContent.content = newValue
        }
    }
    
    public init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(rootView: UIHostingWindowContent(parent: self, content: rootView))
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
    public func windowPosition(_ position: CGPoint) -> some View {
        preference(key: WindowPostionPreferenceKey.self, value: position)
    }
    
    public func windowPosition(x: CGFloat, y: CGFloat) -> some View {
        windowPosition(.init(x: x, y: y))
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
final class WindowPostionPreferenceKey: TakeLastPreferenceKey<CGPoint> {
    
}

public struct UIHostingWindowContent<Content: View>: View {
    @usableFromInline
    weak private(set) var parent: UIWindow?
    
    @usableFromInline
    fileprivate(set) var content: Content
    
    @inlinable
    public var body: some View {
        content.onPreferenceChange(WindowPostionPreferenceKey.self) {
            self.parent?.frame.origin = ($0 ?? CGPoint.zero)
        }
    }
}

#endif
