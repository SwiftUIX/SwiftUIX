//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct FrameReaderProxy {
    public func frame(for identifier: AnyHashable) -> CGRect {
        .zero // TODO: Implement
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
/*public*/ struct FrameReader<Content: View>: View {
    public let namespace: Namespace.ID
    public let content: (FrameReaderProxy) -> Content
    
    public init(
        for namespace: Namespace.ID,
        @ViewBuilder content: @escaping (FrameReaderProxy) -> Content
    ) {
        self.namespace = namespace
        self.content = content
    }
    
    public var body: some View {
        content(FrameReaderProxy())
    }
}

// MARK: - Auxiliary Implementation -

private final class CaptureViewSizePreferenceKey<T: View>: TakeLastPreferenceKey<CGSize> {
    
}

extension View {
    public func captureSize(in binding: SetBinding<CGSize>) -> some View {
        overlay {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: CaptureViewSizePreferenceKey<Self>.self,
                    value: proxy.size
                )
            }
        }
        .onPreferenceChange(CaptureViewSizePreferenceKey<Self>.self) { size in
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
