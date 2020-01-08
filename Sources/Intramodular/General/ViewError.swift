//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct ViewError: CustomStringConvertible, Error {
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
    
    public var localizedDescription: String {
        return description
    }
}
