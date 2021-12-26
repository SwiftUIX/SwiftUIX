//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

protocol _CellProxyBase {
    var globalFrame: CGRect { get }
    
    func invalidateLayout(with context: CellProxy.InvalidationContext)
}

public struct CellProxy {
    public struct InvalidationContext {
        public let newPreferredContentSize: OptionalDimensions?
        
        public init(newPreferredContentSize: OptionalDimensions? = nil) {
            self.newPreferredContentSize = newPreferredContentSize
        }
    }
    
    let base: _CellProxyBase?
    
    public func invalidateLayout(with context: InvalidationContext = .init()) {
        base?.invalidateLayout(with: context)
    }
}

public struct CellReader<Content: View>: View {
    @Environment(\._cellProxy) var _cellProxy
    
    public let content: (CellProxy) -> Content
    
    public init(
        @ViewBuilder content: @escaping (CellProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(_cellProxy ?? .init(base: nil))
    }
}

// MARK: - Auxiliary Implementation -

struct CellProxyEnvironmentKey: EnvironmentKey {
    static let defaultValue: CellProxy? = nil
}

extension EnvironmentValues {
    var _cellProxy: CellProxy? {
        get {
            self[CellProxyEnvironmentKey.self]
        } set {
            self[CellProxyEnvironmentKey.self] = newValue
        }
    }
}
