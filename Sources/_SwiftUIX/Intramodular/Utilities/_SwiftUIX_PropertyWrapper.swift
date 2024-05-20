//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _SwiftUIX_PropertyWrapper {
    associatedtype _SwiftUIX_WrappedValueType
    
    var wrappedValue: _SwiftUIX_WrappedValueType { get }
}

public protocol _SwiftUIX_MutablePropertyWrapper: _SwiftUIX_PropertyWrapper {
    var wrappedValue: _SwiftUIX_WrappedValueType { get set }
}

public protocol _SwiftUIX_MutablePropertyWrapperObject: AnyObject, _SwiftUIX_MutablePropertyWrapper {
    var wrappedValue: _SwiftUIX_WrappedValueType { get set }
}
