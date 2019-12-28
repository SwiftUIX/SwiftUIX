//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol CocoaView: View {
    func isFirstResponder(_: Bool) -> Self
}
