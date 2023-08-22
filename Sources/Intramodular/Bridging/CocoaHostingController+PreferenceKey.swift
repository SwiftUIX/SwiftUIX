//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public final class _ObservedPreferenceValues: ObservableObject {
    @Published var storage: [ObjectIdentifier: Any] = [:]
    
    public init() {
        
    }
    
    public subscript<Key: PreferenceKey>(
        _ key: Key.Type
    ) -> Key.Value? where Key.Value: Equatable {
        get {
            if let _result = storage[ObjectIdentifier(Key.self)] {
                guard let result = _result as? Key.Value else {
                    assertionFailure()
                    
                    return nil
                }
                
                return result
            } else {
                return nil
            }
        }
    }
}

struct PreferenceValueObserver<Key: PreferenceKey>: ViewModifier where Key.Value: Equatable {
    weak var store: _ObservedPreferenceValues?
    
    func body(content: Content) -> some View {
        content.onPreferenceChange(Key.self) { value in
            store?.storage[ObjectIdentifier(Key.self)] = value
        }
    }
}
