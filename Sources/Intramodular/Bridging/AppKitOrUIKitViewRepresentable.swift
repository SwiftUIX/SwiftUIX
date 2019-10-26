//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitViewRepresentable: UIViewRepresentable {
    associatedtype AppKitOrUIKitView where AppKitOrUIKitView == UIViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitView
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitView, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitView, coordinator: Coordinator)
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    
    public func makeUIView(context: Context) -> AppKitOrUIKitView {
        makeAppKitOrUIKitView(context: context)
    }
    
    public func updateUIView(_ view: AppKitOrUIKitView, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    public static func dismantleUIView(_ view: AppKitOrUIKitView, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

#elseif os(macOS)

public protocol AppKitOrUIKitViewRepresentable: NSViewRepresentable {
    associatedtype AppKitOrUIKitView where AppKitOrUIKitView == NSViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitView
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitView, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitView, coordinator: Coordinator)
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
    
    public func makeNSView(context: Context) -> AppKitOrUIKitView {
        makeAppKitOrUIKitView(context: context)
    }
    
    public func updateNSView(_ view: AppKitOrUIKitView, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    public static func dismantleNSView(_ view: AppKitOrUIKitView, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AppKitOrUIKitViewRepresentable {
    public static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitView, coordinator: Coordinator) {
        
    }
}

#endif
