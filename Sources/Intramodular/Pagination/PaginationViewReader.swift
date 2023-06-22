//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A proxy value allowing the pagination views within a view hierarchy to be manipulated programmatically.
public struct PaginationViewProxy: Hashable {
    private let _progressionController = ReferenceBox<ProgressionController?>(nil)
    private let _hostingPageViewController = WeakReferenceBox<AnyObject>(nil)
    
    var hostingPageViewController: _opaque_UIHostingPageViewController? {
        get {
            _hostingPageViewController.value as? _opaque_UIHostingPageViewController
        } set {
            _hostingPageViewController.value = newValue
        }
    }
    
    var progressionController: ProgressionController {
        get {
            _progressionController.value!
        } set {
            _progressionController.value = newValue
        }
    }
    
    public var paginationState: PaginationState {
        hostingPageViewController?.internalPaginationState ?? .init()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hostingPageViewController?.hashValue)
    }
    
    public func scrollTo(_ id: AnyHashable) {
        progressionController.scrollTo(id)
    }
    
    public func moveToPrevious() {
        progressionController.moveToPrevious()
    }
    
    public func moveToNext() {
        progressionController.moveToNext()
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hostingPageViewController === rhs.hostingPageViewController
    }
}

/// A view whose child is defined as a function of a `PaginationViewProxy` targeting the pagination views within the child.
public struct PaginationViewReader<Content: View>: View {
    private let content: (PaginationViewProxy) -> Content
    
    @State private var _paginationViewProxy = PaginationViewProxy()
    
    public init(
        @ViewBuilder content: @escaping (PaginationViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_paginationViewProxy)
            .environment(\._paginationViewProxy, $_paginationViewProxy)
            .background(EmptyView().id(_paginationViewProxy.paginationState))
    }
}

// MARK: - Auxiliary

extension PaginationViewProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<PaginationViewProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _paginationViewProxy: Binding<PaginationViewProxy>? {
        get {
            self[PaginationViewProxy.EnvironmentKey.self]
        } set {
            self[PaginationViewProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
