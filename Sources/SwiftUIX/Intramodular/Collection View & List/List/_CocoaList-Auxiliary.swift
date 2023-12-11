//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct _AnyCocoaListItemID: Hashable {
    let _base: AnyHashable
    
    public var base: Any {
        _base.base
    }
    
    init(_ base: AnyHashable) {
        self._base = base
    }
}

public struct _AnyCocoaListSectionID: Hashable {
    let _base: AnyHashable
    
    public var base: Any {
        _base.base
    }
    
    init(_ base: AnyHashable) {
        self._base = base
    }
}
