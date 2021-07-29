//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// The opaque representation of a view's name.
public struct ViewName {
    @usableFromInline
    var viewType: ObjectIdentifier?
    
    @usableFromInline
    let base: AnyHashable
    
    @usableFromInline
    var isViewType: Bool {
        base == .init(viewType)
    }
    
    public init<H: Hashable>(_ base: H) {
        if let base = base as? ViewName {
            self = base
        } else {
            self.viewType = nil
            self.base = .init(base)
        }
    }
    
    public init<V: View>(_ type: V.Type) {
        self.viewType = .init(type)
        self.base = self.viewType
    }
    
    public init() {
        self.init(UUID())
    }
}

extension ViewName {
    @usableFromInline
    func withViewType<V: View>(_ type: V.Type) -> ViewName {
        var result = self
        
        result.viewType = .init(type)
        
        return result
    }
}

// MARK: - Protocol Implementation -

extension ViewName: CustomStringConvertible {
    public var description: String {
        String(describing: base.base)
    }
}

extension ViewName: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
    
    @inlinable
    public static func ~= (lhs: ViewName, rhs: ViewName) -> Bool {
        if lhs == rhs {
            return true
        } else if lhs.isViewType || rhs.isViewType {
            return lhs.viewType == rhs.viewType
        } else {
            return false
        }
    }
}

extension ViewName: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    @usableFromInline
    var _name: ViewName? {
        get {
            self[DefaultEnvironmentKey<ViewName>.self]
        } set {
            self[DefaultEnvironmentKey<ViewName>.self] = newValue
        }
    }
}
