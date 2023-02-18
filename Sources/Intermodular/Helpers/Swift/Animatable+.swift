//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// Express a view as a function over some animatable data.
public func withAnimatableData<AnimatableData: Hashable & VectorArithmetic, Content: View>(
    _ data: AnimatableData,
    @ViewBuilder content: @escaping (AnimatableData) -> Content
) -> some View {
    ZeroSizeView().modifier(_WithAnimatableData(animatableData: data, _content: content))
}

// MARK: - Auxiliary

struct _WithAnimatableData<AnimatableData: Hashable & VectorArithmetic, _Content: View>: AnimatableModifier {
    var animatableData: AnimatableData
    let _content: (AnimatableData) -> _Content
    
    func body(content: Content) -> some View {
        _content(animatableData).background(ZeroSizeView().id(animatableData))
    }
}
