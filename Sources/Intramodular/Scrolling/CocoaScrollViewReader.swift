//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A proxy value allowing the collection views within a view hierarchy to be manipulated programmatically.
public struct CocoaScrollViewProxy: Hashable {
    private let _baseBox: WeakReferenceBox<AnyObject>
    
    @ReferenceBox var onBaseChange: (() -> Void)? = nil
    
    var base: _opaque_UIHostingScrollView? {
        get {
            _baseBox.value as? _opaque_UIHostingScrollView
        } set {
            _baseBox.value = newValue
            
            onBaseChange?()
        }
    }
    
    #if os(iOS)
    public var underlyingAppKitOrUIKitScrollView: AppKitOrUIKitScrollView? {
        base
    }
    #endif
    
    init(_ base: _opaque_UIHostingScrollView? = nil) {
        self._baseBox = .init(base)
    }
    
    public func scrollTo(_ edge: Edge) {
        base?.scrollTo(edge)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base?.hashValue)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base === rhs.base
    }
}

/// A view whose child is defined as a function of a `ScrollViewProxy` targeting the collection views within the child.
public struct CocoaScrollViewReader<Content: View>: View {
    @Environment(\._cocoaScrollViewProxy) var _environment_cocoaScrollViewProxy
    
    public let content: (CocoaScrollViewProxy) -> Content
    
    @State var _cocoaScrollViewProxy = CocoaScrollViewProxy()
    @State var invalidate: Bool = false
    
    public init(
        @ViewBuilder content: @escaping (CocoaScrollViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_environment_cocoaScrollViewProxy?.wrappedValue ?? _cocoaScrollViewProxy)
            .environment(\._cocoaScrollViewProxy, $_cocoaScrollViewProxy)
            .background {
                PerformAction {
                    _cocoaScrollViewProxy.onBaseChange = {
                        invalidate.toggle()
                    }
                }
                .id(invalidate)
            }
    }
}

// MARK: - Auxiliary Implementation -

extension CocoaScrollViewProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<CocoaScrollViewProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _cocoaScrollViewProxy: Binding<CocoaScrollViewProxy>? {
        get {
            self[CocoaScrollViewProxy.EnvironmentKey.self]
        } set {
            self[CocoaScrollViewProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
