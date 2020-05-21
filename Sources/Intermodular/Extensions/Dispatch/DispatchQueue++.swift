//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Foundation
import Swift

extension DispatchQueue {
    static func asyncOnMainIfNecessary(execute work: @escaping () -> ()) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
