//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

class CocoaPresentationDidAttemptToDismissCallback: Equatable {
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    static func == (lhs: CocoaPresentationDidAttemptToDismissCallback, rhs: CocoaPresentationDidAttemptToDismissCallback) -> Bool {
        return lhs === rhs
    }
}

struct CocoaPresentationDidAttemptToDismissCallbacksPreferenceKey: PreferenceKey {
    typealias Value = [CocoaPresentationDidAttemptToDismissCallback]
    
    static var defaultValue: Value = []
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

public extension View {
    func onCocoaPresentationDidAttemptToDismiss(perform action: @escaping () -> Void) -> some View {
        return preference(key: CocoaPresentationDidAttemptToDismissCallbacksPreferenceKey.self, value: [CocoaPresentationDidAttemptToDismissCallback(action)])
    }
}
