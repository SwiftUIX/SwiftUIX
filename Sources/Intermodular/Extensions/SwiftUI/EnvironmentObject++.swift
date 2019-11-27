//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension EnvironmentObject {
    public var isPresent: Bool {
        return (Mirror(reflecting: self).children.first(where: { $0.label == "_store" })?.value as? ObjectType) != nil
    }
}
