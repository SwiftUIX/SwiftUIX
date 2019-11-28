//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension NavigationLink {
    public init(
        action: @escaping () -> (),
        destination: Destination,
        @ViewBuilder label: () -> Label
    ) {
        let isActive = MutableHeapWrapper(false)
        
        self.init(
            destination: destination,
            isActive: Binding(
                get: { isActive.value },
                set: {
                    if !isActive.value && $0 {
                        action()
                    }
                    
                    isActive.value = $0
                }
            ),
            label: label
        )
    }
}
