//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct CocoaPresentationPreferenceKey: PreferenceKey {
    typealias Value = CocoaPresentation?
    
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let result = nextValue() ?? value
        
        value = result
    }
}

#endif
