//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public struct HorizontalLine: Shape {
    private let alignment: VerticalAlignment
    
    public init(alignment: VerticalAlignment = .center) {
        self.alignment = alignment
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let y: CGFloat
        
        switch alignment {
            case .top:
                y = 0
            case .center:
                y = rect.midY
            case .bottom:
                y = rect.maxY
            case .firstTextBaseline:
                y = 0
            case .lastTextBaseline:
                y = rect.maxY
            default:
                y = rect.midY
        }
        
        path.move(to: .init(x: 0, y: y))
        path.addLine(to: .init(x: rect.maxX, y: y))
        
        return path
    }
}
