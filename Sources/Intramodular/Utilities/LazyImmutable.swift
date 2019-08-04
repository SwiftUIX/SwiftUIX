//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
public struct LazyImmutable<Value> {
    private var _wrappedValue: Value?

    public private(set) var wasInitialized: Bool = false

    public var wrappedValue: Value {
        get {
            guard let _wrappedValue = _wrappedValue else {
                fatalError()
            }

            return _wrappedValue
        } set {
            guard !wasInitialized else {
                fatalError()
            }

            _wrappedValue = newValue
        }
    }

    public init() {

    }
}
