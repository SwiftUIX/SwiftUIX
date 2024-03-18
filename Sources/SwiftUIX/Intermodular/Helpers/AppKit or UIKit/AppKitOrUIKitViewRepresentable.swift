//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A Cocoa-touch view/view controller representable.
public protocol _AppKitOrUIKitRepresentable {
    associatedtype Coordinator
}

public protocol _AppKitOrUIKitViewRepresentableContext<Coordinator> {
    associatedtype Coordinator
    
    var coordinator: Coordinator { get }
    var transaction: Transaction { get }
    var environment: EnvironmentValues { get }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
public protocol AppKitOrUIKitViewRepresentable: _AppKitOrUIKitRepresentable, UIViewRepresentable {
    associatedtype AppKitOrUIKitViewType = UIViewType where AppKitOrUIKitViewType == UIViewType
    
    @MainActor
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    
    @MainActor
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize?
}

public protocol AppKitOrUIKitViewControllerRepresentable: _AppKitOrUIKitRepresentable, UIViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = UIViewControllerType where AppKitOrUIKitViewControllerType == UIViewControllerType
    
    @MainActor
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    @MainActor
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitViewController(
        _ view: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    )
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) -> CGSize?
}
#elseif os(macOS)
public protocol AppKitOrUIKitViewRepresentable: _AppKitOrUIKitRepresentable, NSViewRepresentable {
    associatedtype AppKitOrUIKitViewType where AppKitOrUIKitViewType == NSViewType
    
    @MainActor
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType
    @MainActor
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context)
    
    static func dismantleAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator)
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize?
}

public protocol AppKitOrUIKitViewControllerRepresentable: _AppKitOrUIKitRepresentable, NSViewControllerRepresentable {
    associatedtype AppKitOrUIKitViewControllerType = NSViewControllerType where AppKitOrUIKitViewControllerType == NSViewControllerType
    
    @MainActor
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType
    @MainActor
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context)
    
    @MainActor
    static func dismantleAppKitOrUIKitViewController(_ view: AppKitOrUIKitViewControllerType, coordinator: Coordinator)
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) -> CGSize?
}
#endif

// MARK: - Implementation

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitViewRepresentable {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        nil
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) -> CGSize? {
        nil
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension UIViewRepresentableContext: _AppKitOrUIKitViewRepresentableContext {
    
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        self.sizeThatFits(proposal, view: uiView, context: context)
    }
}

extension AppKitOrUIKitViewRepresentable {
    @MainActor
    public func makeUIView(
        context: Context
    ) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateUIView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        let represented = view as? _AppKitOrUIKitRepresented
        
        represented?.representatableStateFlags.insert(.updateInProgress)
        
        updateAppKitOrUIKitView(view, context: context)
        
        represented?.representatableStateFlags.remove(.updateInProgress)
        
        if let represented, !represented.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            represented.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }
    
    @MainActor
    public static func dismantleUIView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        let represented = view as? _AppKitOrUIKitRepresented
        
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
        
        represented?.representatableStateFlags.insert(.dismantled)
    }
}

extension AppKitOrUIKitViewRepresentable where AppKitOrUIKitViewType: _AppKitOrUIKitRepresented {
    @MainActor
    public func makeUIView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateUIView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        view.representatableStateFlags.insert(.updateInProgress)
        
        updateAppKitOrUIKitView(view, context: context)
        
        view.representatableStateFlags.remove(.updateInProgress)
        
        if !view.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            view.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }
    
    @MainActor
    public static func dismantleUIView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
        
        view.representatableStateFlags.insert(.dismantled)
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = UIViewControllerRepresentableContext<Self>

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: Self.UIViewControllerType,
        context: Self.Context
    ) -> CGSize? {
        self.sizeThatFits(
            proposal,
            viewController: uiViewController,
            context: context
        )
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
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

extension AppKitOrUIKitViewControllerRepresentable where AppKitOrUIKitViewControllerType: _AppKitOrUIKitRepresented {
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
        viewController.representatableStateFlags.insert(.updateInProgress)
        
        updateAppKitOrUIKitViewController(viewController, context: context)
        
        viewController.representatableStateFlags.remove(.updateInProgress)
        
        if !viewController.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            viewController.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }
    
    @MainActor
    public static func dismantleUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
        
        viewController.representatableStateFlags.insert(.dismantled)
    }
}

#elseif os(macOS)
extension NSViewRepresentableContext: _AppKitOrUIKitViewRepresentableContext {
    
}

extension AppKitOrUIKitViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
        
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        self.sizeThatFits(proposal, view: nsView, context: context)
    }
}

extension AppKitOrUIKitViewRepresentable {
    @MainActor
    public func makeNSView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateNSView(
        _ view: AppKitOrUIKitViewType, 
        context: Context
    ) {
        weak var _view = view
        
        guard let view = _view else {
            return
        }
        
        let represented = view as? _AppKitOrUIKitRepresented
        
        represented?.representatableStateFlags.insert(.updateInProgress)

        updateAppKitOrUIKitView(view, context: context)
        
        represented?.representatableStateFlags.remove(.updateInProgress)
        
        if let represented, !represented.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            represented.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }
    
    @MainActor
    public static func dismantleNSView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        let represented = view as? _AppKitOrUIKitRepresented
        
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
        
        represented?.representatableStateFlags.insert(.dismantled)
    }
}

extension AppKitOrUIKitViewRepresentable where AppKitOrUIKitViewType: _AppKitOrUIKitRepresented {
    @MainActor
    public func makeNSView(
        context: Context
    ) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }
    
    @MainActor
    public func updateNSView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        view.representatableStateFlags.insert(.updateInProgress)
        
        updateAppKitOrUIKitView(view, context: context)
        
        view.representatableStateFlags.remove(.updateInProgress)
        
        if !view.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            view.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }

    @MainActor
    public static func dismantleNSView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
        
        view.representatableStateFlags.insert(.dismantled)
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
    public typealias Context = NSViewControllerRepresentableContext<Self>
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsViewController: Self.NSViewControllerType,
        context: Self.Context
    ) -> CGSize? {
        self.sizeThatFits(
            proposal,
            viewController: nsViewController,
            context: context
        )
    }
}

extension AppKitOrUIKitViewControllerRepresentable {
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

extension AppKitOrUIKitViewControllerRepresentable where AppKitOrUIKitViewControllerType: _AppKitOrUIKitRepresented {
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
        viewController.representatableStateFlags.insert(.updateInProgress)

        updateAppKitOrUIKitViewController(viewController, context: context)
        
        viewController.representatableStateFlags.remove(.updateInProgress)
        
        if !viewController.representatableStateFlags.contains(.didUpdateAtLeastOnce) {
            viewController.representatableStateFlags.insert(.didUpdateAtLeastOnce)
        }
    }
    
    @MainActor
    public static func dismantleNSViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
        
        viewController.representatableStateFlags.insert(.dismantled)
    }
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
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

public struct _SwiftUIX_EditableAppKitOrUIKitViewRepresentableContext: _AppKitOrUIKitViewRepresentableContext {
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
    
    public init(_ context: some _AppKitOrUIKitViewRepresentableContext) {
        self.transaction = context.transaction
        self.environment = context.environment
    }
}

extension _AppKitOrUIKitViewRepresentableContext {
    public func _editable() -> _SwiftUIX_EditableAppKitOrUIKitViewRepresentableContext {
        .init(self)
    }
}
