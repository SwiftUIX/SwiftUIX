//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension LocalizedStringKey {
    public var _SwiftUIX_key: String {
        guard let key = Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String else {
            assertionFailure()
            
            return ""
        }
        
        return key
    }
    
    public var _SwiftUIX_string: String {
        NSLocalizedString(_SwiftUIX_key, comment: "")
    }
}
