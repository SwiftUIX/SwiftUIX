//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitViewRepresentable: UIViewRepresentable {
    associatedtype AppKitOrUIKitViewType = UIViewType where AppKitOrUIKitViewType == UIViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

public protocol AppKitOrUIKitViewControllerRepresentable: UIViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = UIViewControllerType where AppKitOrUIKitViewControllerType == UIViewControllerType
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    static func dismantleAppKitOrUIKitViewController(_ view: AppKitOrUIKitViewControllerType, coordinator: Coordinator)
}

#elseif os(macOS)

public protocol AppKitOrUIKitViewRepresentable: NSViewRepresentable {
    associatedtype AppKitOrUIKitViewType where AppKitOrUIKitViewType == NSViewType
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

public protocol AppKitOrUIKitViewControllerRepresentable: NSViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = NSViewControllerType where AppKitOrUIKitViewControllerType == NSViewControllerType
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    static func dismantleAppKitOrUIKitViewController(_ view: AppKitOrUIKitViewControllerType, coordinator: Coordinator)
}

#endif

// MARK: - Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

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

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = UIViewControllerRepresentableContext<Self>
    
    public func makeUIViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewController(context: context)
    }
    
    public func updateUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewController(viewController, context: context)
    }
    
    public static func dismantleUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
    }
}

#elseif os(macOS)

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

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = NSViewControllerRepresentableContext<Self>
    
    public func makeNSViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewController(context: context)
    }
    
    public func updateNSViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewController(viewController, context: context)
    }
    
    public static func dismantleNSViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
    }
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AppKitOrUIKitViewRepresentable {
    public static func dismantleAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    public static func dismantleAppKitOrUIKitViewController(
        _ view: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        
    }
}

#endif
