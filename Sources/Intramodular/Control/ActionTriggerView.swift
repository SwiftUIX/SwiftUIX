//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_ActionTriggerView: opaque_View {
    func onPrimaryTrigger(perform: @escaping () -> ()) -> Self
}

/// A view with the primary goal of triggering an action.
public protocol ActionTriggerView: opaque_ActionTriggerView, View {
    func onPrimaryTrigger(perform: @escaping () -> ()) -> Self
}
