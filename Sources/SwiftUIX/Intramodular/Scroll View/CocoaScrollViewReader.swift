//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Foundation
import Swift
import SwiftUI

/// A proxy value allowing the collection views within a view hierarchy to be manipulated programmatically.
@_documentation(visibility: internal)
public struct CocoaScrollViewProxy {
    @UnsafeWeakReferenceBox
    var base: (any _AppKitOrUIKitHostingScrollViewType)?
    
    init(base: (any _AppKitOrUIKitHostingScrollViewType)? = nil) {
        self.base = base
    }
    
    public func scrollTo(_ edge: Edge) {
        guard let base else {
            assertionFailure()
            
            return
        }
        
        base.scrollTo(edge)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base === rhs.base
    }
}

/// A view whose child is defined as a function of a `ScrollViewProxy` targeting the collection views within the child.
@_documentation(visibility: internal)
public struct CocoaScrollViewReader<Content: View>: View {
    @Environment(\._cocoaScrollViewProxy) var _environment_cocoaScrollViewProxy
    
    public let content: (CocoaScrollViewProxy) -> Content
    
    @PersistentObject var _cocoaScrollViewProxy = _SwiftUIX_ObservableReferenceBox<CocoaScrollViewProxy?>(.init())
    
    @State var invalidate: Bool = false
    
    public init(
        @ViewBuilder content: @escaping (CocoaScrollViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_cocoaScrollViewProxy.wrappedValue!)
            .environment(\._cocoaScrollViewProxy, _cocoaScrollViewProxy)
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    fileprivate struct _CocoaScrollViewProxyKey: SwiftUI.EnvironmentKey {
        static let defaultValue: _SwiftUIX_ObservableReferenceBox<CocoaScrollViewProxy?> = _SwiftUIX_ObservableReferenceBox(nil)
    }
    
    var _cocoaScrollViewProxy: _SwiftUIX_ObservableReferenceBox<CocoaScrollViewProxy?> {
        get {
            self[_CocoaScrollViewProxyKey.self]
        } set {
            self[_CocoaScrollViewProxyKey.self] = newValue
        }
    }
}

#endif
