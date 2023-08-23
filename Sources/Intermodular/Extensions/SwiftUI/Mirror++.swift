//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Mirror {
    subscript(_SwiftUIX_keyPath path: String) -> Any? {
        guard !path.isEmpty else {
            assertionFailure()
            
            return nil
        }
        
        var components = path.components(separatedBy: ".")
        let first = components.removeFirst()
        
        guard let value = children.first(where: { $0.label == first })?.value else {
            return nil
        }
        
        if components.isEmpty {
            return value
        } else {
            return Mirror(reflecting: value)[_SwiftUIX_keyPath: components.joined(separator: ".")]
        }
    }
    
    static func inspect(
        _ object: Any,
        with action: (Mirror.Child) -> Void
    ) {
        Mirror(reflecting: object).children.forEach(action)
    }
}
