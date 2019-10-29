//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitViewRepresentable: UIViewRepresentable {
    associatedtype AppKitOrUIKitViewType where AppKitOrUIKitViewType == UIViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    
    public func makeUIView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    public func updateUIView(_ view: AppKitOrUIKitViewType, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    public static func dismantleUIView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

#elseif os(macOS)

public protocol AppKitOrUIKitViewRepresentable: NSViewRepresentable {
    associatedtype AppKitOrUIKitViewType where AppKitOrUIKitViewType == NSViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
    
    public func makeNSView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    public func updateNSView(_ view: AppKitOrUIKitViewType, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    public static func dismantleNSView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AppKitOrUIKitViewRepresentable {
    public static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        
    }
}

#endif
