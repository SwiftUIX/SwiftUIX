//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol PresentationModeProtocol {
    var isPresented: Bool { get }
    
    mutating func dismiss()
}

// MARK: - Concrete Implementations -

extension PresentationMode: PresentationModeProtocol {
    
}
