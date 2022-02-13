//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol _CollectionViewProxyBase: AppKitOrUIKitViewController {
    var collectionViewContentSize: CGSize { get }
    
    func invalidateLayout()
    
    func scrollToTop(anchor: UnitPoint?, animated: Bool)
    func scrollToLast(anchor: UnitPoint?, animated: Bool)
    
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func scrollTo<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint?)
    func scrollTo<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint?)
    
    func select<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func select<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint?)
    func select<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint?)
    
    func selectNextItem(anchor: UnitPoint?)
    func selectPreviousItem(anchor: UnitPoint?)
    
    func deselect<ID: Hashable>(_ id: ID)
    
    func selection<ID: Hashable>(for id: ID) -> Binding<Bool>
    
    func _snapshot() -> AppKitOrUIKitImage?
}

/// A proxy value allowing the collection views within a view hierarchy to be manipulated programmatically.
public struct CollectionViewProxy: Hashable {
    private let _baseBox: WeakReferenceBox<AnyObject>
    
    @ReferenceBox var onBaseChange: (() -> Void)? = nil
    
    var base: _CollectionViewProxyBase? {
        get {
            _baseBox.value as? _CollectionViewProxyBase
        } set {
            guard _baseBox.value !== newValue else {
                return
            }

            _baseBox.value = newValue

            onBaseChange?()
        }
    }
    
    public var contentSize: CGSize {
        base?.collectionViewContentSize ?? .zero
    }
    
    init(_ base: _CollectionViewProxyBase? = nil) {
        self._baseBox = .init(base)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base?.hashValue)
    }
    
    public func invalidateLayout() {
        _assertResolutionOfCollectionView()
        
        base?.invalidateLayout()
    }
    
    public func scrollToTop(anchor: UnitPoint? = nil, animated: Bool = true) {
        _assertResolutionOfCollectionView()
        
        base?.scrollToTop(anchor: anchor, animated: animated)
    }
    
    public func scrollToLast(anchor: UnitPoint? = nil, animated: Bool = true) {
        _assertResolutionOfCollectionView()
        
        base?.scrollToLast(anchor: anchor, animated: animated)
    }
    
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        base?.scrollTo(id, anchor: anchor)
    }
    
    public func selection<ID: Hashable>(for id: ID) -> Binding<Bool> {
        _assertResolutionOfCollectionView()
        
        return base?.selection(for: id) ?? .constant(false)
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        base?.select(id, anchor: anchor)
    }
    
    public func selectNextItem(anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        base?.selectNextItem(anchor: anchor)
    }
    
    public func selectPreviousItem(anchor: UnitPoint? = nil) {
        _assertResolutionOfCollectionView()
        
        base?.selectPreviousItem(anchor: anchor)
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        _assertResolutionOfCollectionView()
        
        base?.deselect(id)
    }
    
    public func _snapshot() -> AppKitOrUIKitImage? {
        _assertResolutionOfCollectionView()
        
        return base?._snapshot()
    }
    
    private func _assertResolutionOfCollectionView() {
        // assert(base != nil, "CollectionViewProxy couldn't resolve a collection view")
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base === rhs.base
    }
}

/// A view whose child is defined as a function of a `CollectionViewProxy` targeting the collection views within the child.
public struct CollectionViewReader<Content: View>: View {
    @Environment(\._collectionViewProxy) var _environment_collectionViewProxy
    
    public let content: (CollectionViewProxy) -> Content
    
    @State var _collectionViewProxy = CollectionViewProxy()
    @State var invalidate: Bool = false
    
    public init(
        @ViewBuilder content: @escaping (CollectionViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_environment_collectionViewProxy?.wrappedValue ?? _collectionViewProxy)
            .environment(\._collectionViewProxy, $_collectionViewProxy)
            .background {
                PerformAction {
                    if _collectionViewProxy.onBaseChange == nil {
                        _collectionViewProxy.onBaseChange = {
                            invalidate.toggle()
                        }
                    }
                }
                .id(invalidate)
            }
    }
}

// MARK: - Auxiliary Implementation -

extension CollectionViewProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<CollectionViewProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _collectionViewProxy: Binding<CollectionViewProxy>? {
        get {
            self[CollectionViewProxy.EnvironmentKey.self]
        } set {
            self[CollectionViewProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
