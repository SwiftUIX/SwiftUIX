//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// The opaque representation of a view's name.
public struct ViewName: CustomStringConvertible, Hashable {
    private let baseType: ObjectIdentifier
    private let base: AnyHashable
    
    public let description: String
    
    public init<H: Hashable>(_ base: H) {
        if let base = base as? ViewName {
            self = base
        } else {
            self.baseType = .init(type(of: base))
            self.base = .init(base)
            self.description = String(describing: base)
        }
    }
    
    public init<V: View>(_ type: V.Type) {
        self.baseType = .init(type)
        self.base = baseType
        self.description = String(describing: base)
    }
}

// MARK: - Auxiliary Implementation -

public struct _ViewNamePreferenceKeyValue {
    let name: ViewName
    let bounds: Anchor<CGRect>
    
    @usableFromInline
    init(name: ViewName, bounds: Anchor<CGRect>) {
        self.name = name
        self.bounds = bounds
    }
}

extension EnvironmentValues {
    public var viewName: ViewName? {
        get {
            self[DefaultEnvironmentKey<ViewName>]
        } set {
            self[DefaultEnvironmentKey<ViewName>] = newValue
        }
    }
}
