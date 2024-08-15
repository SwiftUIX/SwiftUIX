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
        // Check if the code needs to be executed asynchronously on the main
        let shouldRunAsync = force ?? !Thread.isMainThread

        if shouldRunAsync {
            DispatchQueue.main.async {
                MainActor.backportAssumeIsolated(work)
            }
        } else {
            MainActor.backportAssumeIsolated(work)
        }
    }
}

extension MainActor {
    /// Backport version of iOS 17 `assumIsolated` function.
    @_spi(Internal)
    @_transparent
    public static func backportAssumeIsolated(_ work: @MainActor @escaping () -> Void) {
        if #available(iOS 17.0, *) {
            assumeIsolated {
                work()
            }
        } else {
            Task { @MainActor in
                work()
            }
        }
    }
}
