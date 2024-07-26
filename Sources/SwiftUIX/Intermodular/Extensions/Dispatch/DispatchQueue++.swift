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
        @_implicitSelfCapture execute work: @MainActor @escaping () -> ()
    ) {
        if let force {
            guard force == false else {
                DispatchQueue.main.async(execute: {
                    MainActor.assumeIsolated {
                        work()
                    }
                })
                
                return
            }
        }
        
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                work()
            }
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
