//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public struct _AnyCocoaListItemID: Hashable {
    let _base: AnyHashable
    
    public var base: Any {
        _base.base
    }
    
    init(_ base: AnyHashable) {
        self._base = base
    }
}

@_documentation(visibility: internal)
public struct _AnyCocoaListSectionID: Hashable {
    let _base: AnyHashable
    
    public var base: Any {
        _base.base
    }
    
    init(_ base: AnyHashable) {
        self._base = base
    }
}
