//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swift

// A view that depicts the progress of a task over time.
public struct ProgressBar: View {
    public let value: CGFloat

    public init(_ value: CGFloat) {
        self.value = value
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment.topLeading) {
                Capsule()
                    .frame(width: geometry.size.width)
                    .opacity(0.3)
                Capsule()
                    .frame(width: geometry.size.width * self.value)
            }
        }
    }
}
