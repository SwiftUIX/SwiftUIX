//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct DebugSquare: View {
    public enum Size {
        case large
        case medium
        case small
    }
    
    private let size: Size
    private let color: Color
    
    fileprivate var squareFrame: CGSize {
        switch size {
            case .large:
                return .init(width: 512, height: 512)
            case .medium:
                return .init(width: 256, height: 256)
            case .small:
                return .init(width: 128, height: 128)
        }
    }

    public init(size: Size = .large, color: Color = .red) {
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        Rectangle()
            .fill(color)
            .frame(squareFrame)
    }
}
