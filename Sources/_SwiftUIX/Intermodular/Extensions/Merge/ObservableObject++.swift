//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch

extension ObservableObject {
    public func _objectWillChange_send(
        deferred: Bool = false
    ) where ObjectWillChangePublisher == ObservableObjectPublisher {        
        if deferred {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.objectWillChange.send()
            }
        } else {
            objectWillChange.send()
        }
    }
}
