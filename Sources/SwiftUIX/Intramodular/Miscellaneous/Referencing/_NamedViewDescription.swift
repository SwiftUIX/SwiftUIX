//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view description.
///
/// The description is composed of two things - the view's name and the view's frame.
@_documentation(visibility: internal)
public struct _NamedViewDescription: Hashable {
    @usableFromInline
    let name: AnyHashable
    @usableFromInline
    let id: AnyHashable?
    @usableFromInline
    let globalBounds: CGRect
    
    @usableFromInline
    init(
        name: AnyHashable,
        id: AnyHashable?,
        geometry: GeometryProxy
    ) {
        self.name = name
        self.id = id
        self.globalBounds = geometry.frame(in: .global)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
        hasher.combine(globalBounds.origin.x)
        hasher.combine(globalBounds.origin.y)
        hasher.combine(globalBounds.size.width)
        hasher.combine(globalBounds.size.height)
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        
        guard lhs.id == rhs.id else {
            return false
        }
        
        guard lhs.globalBounds == rhs.globalBounds else {
            return false
        }
        
        return true
    }
}
