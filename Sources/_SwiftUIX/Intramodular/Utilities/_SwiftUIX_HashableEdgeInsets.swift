//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@propertyWrapper
@_documentation(visibility: internal)
public struct _SwiftUIX_HashableEdgeInsets: Hashable, @unchecked Sendable {
    public static var zero: Self {
        Self(wrappedValue: .zero)
    }
    
    public var wrappedValue: EdgeInsets
    
    public init(wrappedValue: EdgeInsets) {
        self.wrappedValue = wrappedValue
    }
    
    public var top: CGFloat {
        get {
            wrappedValue.top
        } set {
            wrappedValue.top = newValue
        }
    }
    
    public var leading: CGFloat {
        get {
            wrappedValue.leading
        } set {
            wrappedValue.leading = newValue
        }
    }
    
    public var bottom: CGFloat {
        get {
            wrappedValue.bottom
        } set {
            wrappedValue.bottom = newValue
        }
    }
    
    public var trailing: CGFloat {
        get {
            wrappedValue.trailing
        } set {
            wrappedValue.trailing = newValue
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(leading)
        hasher.combine(bottom)
        hasher.combine(trailing)
    }
}
