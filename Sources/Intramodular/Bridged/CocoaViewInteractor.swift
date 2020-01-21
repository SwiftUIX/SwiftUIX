//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol CocoaViewInteractor {
    var isFirstResponder: Bool { get }
    
    func becomeFirstResponder() -> Bool
    func resignFirstResponder() -> Bool
}
