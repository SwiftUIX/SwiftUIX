//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Foundation
import Swift

extension DispatchQueue {
    @_spi(Internal)
    @_transparent
    public static func asyncOnMainIfNecessary(
        _ necessary: Bool? = nil,
        execute work: @escaping () -> ()
    ) {
        if let necessary {
            guard necessary == false else {
                DispatchQueue.main.async(execute: work)
                
                return
            }
        }
        
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
