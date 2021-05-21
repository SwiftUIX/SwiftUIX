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
}

extension CGRect {
    public init(
        size: CGSize,
        container: CGSize,
        alignment: Alignment,
        inside: Bool
    ) {
        self = .zero
        
        self.size = size
        
        if inside {
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
        } else {
            switch alignment.horizontal {
                case .leading:
                    origin.x = -size.width
                case .center:
                    origin.x = (container.width - size.width) / 2
                case .trailing:
                    origin.x = container.width
                default:
                    break
            }
            
            switch alignment.vertical {
                case .top:
                    origin.y = -size.height
                case .center:
                    origin.y = (container.height - size.height) / 2
                case .bottom:
                    origin.y = container.height
                default:
                    break
            }
        }
    }
}

extension CGRect {
    func inflate(by factor: CGFloat) -> CGRect {
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
    
    func rounded(_ rule: FloatingPointRoundingRule) -> CGRect {
        .init(
            x: minX.rounded(rule),
            y: minY.rounded(rule),
            width: width.rounded(rule),
            height: height.rounded(rule)
        )
    }
}
