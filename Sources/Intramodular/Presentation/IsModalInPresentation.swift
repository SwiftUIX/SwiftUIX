//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

struct IsModalInPresentation: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View {
    public func isModalInPresentation(_ value: Bool) -> some View {
        preference(key: IsModalInPresentation.self, value: value)
    }
}
