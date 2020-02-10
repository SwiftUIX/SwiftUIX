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
    
    public var description: String {
        return base.description
    }
        
    public init<H: Hashable>(_ base: H) {
        if let base = base as? ViewName {
            self = base
        } else {
            self.baseType = .init(type(of: base))
            self.base = .init(base)
        }
    }
    
    public init<V: View>(_ type: V.Type) {
        self.init(ObjectIdentifier(type))
    }
}

// MARK: - Auxiliary Implementation -

struct ViewNamePreferenceKeyValue {
    let name: ViewName
    let bounds: Anchor<CGRect>
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
