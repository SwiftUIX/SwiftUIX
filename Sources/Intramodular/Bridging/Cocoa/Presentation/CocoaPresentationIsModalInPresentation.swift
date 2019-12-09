//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct CocoaPresentationIsModalInPresentationPreferenceKey: PreferenceKey {
    typealias Value = Bool?
    
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue() ?? value
    }
}

public extension View {
    func cocoaPresentationIsModalInPresentation(_ value: Bool) -> some View {
        return preference(key: CocoaPresentationIsModalInPresentationPreferenceKey.self, value: value)
    }
}
