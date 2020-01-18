//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

extension CGRect {
    public var minimumDimensionLength: CGFloat {
        min(width, height)
    }
    
    public var maximumDimensionLength: CGFloat {
        max(width, height)
    }
    
    public func inflate(by factor: CGFloat) -> CGRect {
        let x = origin.x
        let y = origin.y
        let w = width
        let h = height
        
        let newW = w * factor
        let newH = h * factor
        let newX = x + ((w - newW) / 2)
        let newY = y + ((h - newH) / 2)
        
        return .init(x: newX, y: newY, width: newW, height: newH)
    }
    
    public init(size: CGSize, container: CGSize, alignment: Alignment) {
        self = .zero
        
        self.size = size
        
        switch alignment.horizontal {
            case .leading:
                origin.x = 0
            case .center:
                origin.x = (container.width - size.width) / 2
            case .trailing:
                origin.x = container.width - size.width
            default:
                break
        }
        
        switch alignment.vertical {
            case .top:
                origin.y = 0
            case .center:
                origin.y = (container.height - size.height) / 2
            case .bottom:
                origin.y = container.height - size.height
            default:
                break
        }
    }
}
