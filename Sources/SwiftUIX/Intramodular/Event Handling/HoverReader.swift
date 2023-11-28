//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(visionOS)

import SwiftUI

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct HoverProxy: Hashable {
    public var isHovering: Bool
}

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct HoverReader<Content: View>: View {
    let content: (HoverProxy) -> Content
    
    public init(@ViewBuilder content: @escaping (HoverProxy) -> Content) {
        self.content = content
    }
    
    @State var isHovering: Bool = false
    
    public var body: some View {
        content(HoverProxy(isHovering: isHovering))
            .onHover {
                guard isHovering != $0 else {
                    return
                }
                
                isHovering = $0
            }
    }
}

#endif
