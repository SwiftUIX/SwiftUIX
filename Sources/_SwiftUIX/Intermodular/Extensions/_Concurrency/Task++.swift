//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Task where Success == Never, Failure == Never {
    public static func _SwiftUIX_sleep(seconds: TimeInterval) async throws {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
