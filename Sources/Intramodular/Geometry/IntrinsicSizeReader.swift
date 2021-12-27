//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A container view that recursively defines its content as a function of the content's size.
public struct IntrinsicSizeReader<Content: View>: View {
    private let content: (CGSize) -> Content

    @State private var size: CGSize = .zero
    
    public init(@ViewBuilder _ content: @escaping (CGSize) -> Content) {
        self.content = content
    }
        
    public var body: some View {
        content(size).background {
            GeometryReader { geometry in
                PerformAction {
                    if self.size != geometry.size {
                        self.size = geometry.size
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}
