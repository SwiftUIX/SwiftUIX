//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private final class CaptureViewSizePreferenceKey<T: View>: TakeLastPreferenceKey<CGSize> {
    
}

extension View {
    public func captureSize(in binding: SetBinding<CGSize>) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(
                key: CaptureViewSizePreferenceKey<Self>.self,
                value: proxy.size
            )
        }).onPreferenceChange(CaptureViewSizePreferenceKey<Self>.self) { size in
            if let size = size {
                binding.wrappedValue = size
            }
        }
        .preference(key: CaptureViewSizePreferenceKey<Self>.self, value: nil)
    }
    
    public func captureSize(in binding: Binding<CGSize>) -> some View {
        captureSize(in: SetBinding(binding))
    }
}
