//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct _CollectionViewItemContent {
    
}

extension _CollectionViewItemContent {
    public struct ResolvedView: View {
        private let base: AnyView
        
        public var body: some View {
            base
        }
        
        init<T: View>(_ base: T) {
            self.base = base.eraseToAnyView()
        }
        
        func _precomputedDimensionsThatFit(
            in dimensions: OptionalDimensions
        ) -> OptionalDimensions? {
            // FIXME: Implement using view traits
            // base._opaque_frameModifier.dimensionsThatFit(in: dimensions)
            
            return nil
        }
    }
}
