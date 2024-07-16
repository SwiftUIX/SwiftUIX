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
        force: Bool? = nil,
        @_implicitSelfCapture execute work: @escaping () -> ()
    ) {
        if let force {
            guard force == false else {
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
