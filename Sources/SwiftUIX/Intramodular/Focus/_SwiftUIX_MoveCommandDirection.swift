//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public enum _SwiftUIX_MoveCommandDirection {
    case up
    case down
    case left
    case right
}

extension Array where Element == CGRect {
    func selectionIndex(
        after currentSelection: Int?,
        direction: _SwiftUIX_MoveCommandDirection
    ) -> Int? {
        guard let currentSelection else {
            return nil
        }
        
        guard self.count > 0 && currentSelection >= 0 && currentSelection < self.count else {
            return currentSelection
        }
        
        let currentRect = self[currentSelection]
        
        func distance(from: CGRect, to: CGRect) -> CGFloat {
            let dx = to.midX - from.midX
            let dy = to.midY - from.midY
            
            return sqrt(dx * dx + dy * dy)
        }
        
        let filteredRects: [CGRect]
        
        switch direction {
            case .up:
                filteredRects = self.filter({ $0.maxY < currentRect.minY })
            case .down:
                filteredRects = self.filter({ $0.minY > currentRect.maxY })
            case .left:
                filteredRects = self.filter({ $0.maxX < currentRect.minX })
            case .right:
                filteredRects = self.filter({ $0.minX > currentRect.maxX })
        }
        
        let nearestRect = filteredRects.min {
            distance(from: currentRect, to: $0) < distance(from: currentRect, to: $1)
        }
        
        return nearestRect.map {
            self.firstIndex(of: $0) ?? currentSelection
        }
    }
    
}

// MARK: - Auxiliary

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _SwiftUIX_MoveCommandDirection {
    public init?(from shortcut: KeyboardShortcut) {
        switch shortcut.key {
            case .upArrow:
                self = .up
            case .downArrow:
                self = .down
            case .leftArrow:
                self = .left
            case .rightArrow:
                self = .right
            default:
                return nil
        }
    }
}

#if os(macOS)
extension _SwiftUIX_MoveCommandDirection {
    public init(_ direction: MoveCommandDirection) {
        switch direction {
            case .up:
                self = .up
            case .down:
                self = .down
            case .left:
                self = .left
            case .right:
                self = .right
            default:
                assertionFailure()
                
                self = .up
        }
    }
}

extension MoveCommandDirection {
    public init(_ direction: _SwiftUIX_MoveCommandDirection) {
        switch direction {
            case .up:
                self = .up
            case .down:
                self = .down
            case .left:
                self = .left
            case .right:
                self = .right
        }
    }
}
#endif
