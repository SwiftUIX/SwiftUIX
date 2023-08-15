//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _SwiftUIX_AppKitOrUIKitViewRepresentableContext {
    associatedtype Coordinator
    
    var coordinator: Coordinator { get }
    var transaction: Transaction { get }
    var environment: EnvironmentValues { get }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
public protocol AppKitOrUIKitViewRepresentable: UIViewRepresentable {
    associatedtype AppKitOrUIKitViewType = UIViewType where AppKitOrUIKitViewType == UIViewType
    
    @MainActor
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    
    @MainActor
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

public protocol AppKitOrUIKitViewControllerRepresentable: UIViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = UIViewControllerType where AppKitOrUIKitViewControllerType == UIViewControllerType
    
    @MainActor
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    @MainActor
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitViewController(_ view: AppKitOrUIKitViewControllerType, coordinator: Coordinator)
}
#elseif os(macOS)
public protocol AppKitOrUIKitViewRepresentable: NSViewRepresentable {
    associatedtype AppKitOrUIKitViewType where AppKitOrUIKitViewType == NSViewType
    
    @MainActor
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    @MainActor
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
}

public protocol AppKitOrUIKitViewControllerRepresentable: NSViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = NSViewControllerType where AppKitOrUIKitViewControllerType == NSViewControllerType
    
    @MainActor
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    @MainActor
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitViewController(_ view: AppKitOrUIKitViewControllerType, coordinator: Coordinator)
}
#endif

// MARK: - Implementation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension UIViewRepresentableContext: _SwiftUIX_AppKitOrUIKitViewRepresentableContext {
    
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    
    @MainActor
    public func makeUIView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateUIView(_ view: AppKitOrUIKitViewType, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    @MainActor
    public static func dismantleUIView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = UIViewControllerRepresentableContext<Self>
    
    @MainActor
    public func makeUIViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewController(context: context)
    }
    
    @MainActor
    public func updateUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewController(viewController, context: context)
    }
    
    @MainActor
    public static func dismantleUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
    }
}

#elseif os(macOS)
extension NSViewRepresentableContext: _SwiftUIX_AppKitOrUIKitViewRepresentableContext {
    
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
    
    @MainActor
    public func makeNSView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateNSView(_ view: AppKitOrUIKitViewType, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }
    
    @MainActor
    public static func dismantleNSView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = NSViewControllerRepresentableContext<Self>
    
    @MainActor
    public func makeNSViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewController(context: context)
    }
    
    @MainActor
    public func updateNSViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewController(viewController, context: context)
    }
    
    @MainActor
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
    @MainActor
    public static func dismantleAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    @MainActor
    public static func dismantleAppKitOrUIKitViewController(
        _ view: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        
    }
}
#endif

// MARK: - Auxiliary

public struct _SwiftUIX_EditableAppKitOrUIKitViewRepresentableContext: _SwiftUIX_AppKitOrUIKitViewRepresentableContext {
    public var coordinator: Void = ()
    public var transaction: Transaction
    public var environment: EnvironmentValues
    
    public init(
        transaction: Transaction = .init(),
        environment: EnvironmentValues
    ) {
        self.transaction = transaction
        self.environment = environment
    }
    
    public init(_ context: some _SwiftUIX_AppKitOrUIKitViewRepresentableContext) {
        self.transaction = context.transaction
        self.environment = context.environment
    }
}

extension _SwiftUIX_AppKitOrUIKitViewRepresentableContext {
    public func _editable() -> _SwiftUIX_EditableAppKitOrUIKitViewRepresentableContext {
        .init(self)
    }
}
