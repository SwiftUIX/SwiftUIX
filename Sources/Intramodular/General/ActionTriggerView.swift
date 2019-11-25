//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view with the primary goal of triggering an action.
public protocol ActionTriggerView: View {
    func onPrimaryAction(_: @escaping () -> ()) -> Self
}
