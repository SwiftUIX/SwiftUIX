//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

@propertyWrapper
@_documentation(visibility: internal)
public struct _SwiftUIX_RenderIgnored<Wrapped>: Hashable, DynamicProperty {
    @ViewStorage private var wrappedValueBox: Wrapped
    
    public var wrappedValue: Wrapped
    
    private var _hasUpdatedOnce: Bool = false
    private var _randomID = Int.random(in: 0...Int.max)
    
    public var projectedValue: Self {
        self
    }
    
    public init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
        self._wrappedValueBox = .init(wrappedValue: wrappedValue)
    }
    
    public mutating func update() {
        if !_hasUpdatedOnce {
            _hasUpdatedOnce = true
        }
        
        wrappedValueBox = wrappedValue
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._hasUpdatedOnce && rhs._hasUpdatedOnce else {
            return lhs._randomID == rhs._randomID
        }
        
        return lhs._wrappedValueBox.id == rhs._wrappedValueBox.id
    }
    
    public func hash(into hasher: inout Hasher) {
        if _hasUpdatedOnce {
            hasher.combine(_randomID)
        }
        
        hasher.combine(_wrappedValueBox.id)
    }
}
