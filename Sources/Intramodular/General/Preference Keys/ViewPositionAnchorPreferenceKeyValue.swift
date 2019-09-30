//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct ViewPositionAnchorPreferenceKeyValue<V: View> {
    public let bounds: Anchor<CGRect>
    
    public init(bounds: Anchor<CGRect>) {
        self.bounds = bounds
    }
}

// MARK: - Helpers -

public typealias TakeFirstViewPositionAnchorPreferenceKey<V: View> = TakeFirstPreferenceKey<ViewPositionAnchorPreferenceKeyValue<V>>
public typealias TakeLastViewPositionAnchorPreferenceKey<V: View> = TakeLastPreferenceKey<ViewPositionAnchorPreferenceKeyValue<V>>

extension View {
    public func takeFirstViewPositionAnchorPreference() -> some View {
        let key = TakeFirstViewPositionAnchorPreferenceKey<Self>.self
        
        return anchorPreference(key: key, value: .bounds) { value in
            ViewPositionAnchorPreferenceKeyValue(bounds: value)
        }
    }
    
    public func takeLastViewPositionAnchorPreference() -> some View {
        let key = TakeLastViewPositionAnchorPreferenceKey<Self>.self
        
        return anchorPreference(key: key, value: .bounds) { value in
            ViewPositionAnchorPreferenceKeyValue(bounds: value)
        }
    }
}

extension View {
    public func overlayWithFirstViewPosition<V: View, T: View>(of type: V.Type, transform: @escaping (ViewPositionAnchorPreferenceKeyValue<V>?) -> T) -> some View {
        overlayPreferenceValue(TakeFirstViewPositionAnchorPreferenceKey<V>.self) {
            transform($0)
        }
    }

    public func backgroundWithFirstViewPosition<V: View, T: View>(of type: V.Type, transform: @escaping (ViewPositionAnchorPreferenceKeyValue<V>?) -> T) -> some View {
        backgroundPreferenceValue(TakeFirstViewPositionAnchorPreferenceKey<V>.self) {
            transform($0)
        }
    }
}
