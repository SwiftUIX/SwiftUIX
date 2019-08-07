//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

// A view that depicts the progress of a task over time.
public struct ProgressBar: View {
    private let value: CGFloat

    public init(_ value: CGFloat) {
        self.value = value
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Capsule()
                    .frame(width: geometry.size.width)
                    .opacity(0.3)
                Capsule()
                    .frame(width: geometry.size.width * self.value)
            }
        }
    }
}
