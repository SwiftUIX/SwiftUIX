//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private final class CaptureViewSizePreferenceKey: TakeLastPreferenceKey<CGSize> {
    
}

extension View {
    public func captureSize(in binding: SetBinding<CGSize>) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(
                key: CaptureViewSizePreferenceKey.self,
                value: proxy.size
            )
        }).onPreferenceChange(CaptureViewSizePreferenceKey.self) { size in
            if let size = size {
                binding.wrappedValue = size
            }
        }
        .preference(key: CaptureViewSizePreferenceKey.self, value: nil)
    }
}
