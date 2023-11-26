//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(tvOS, unavailable)
extension DragGesture.Value {
    public struct Direction: OptionSet {
        public static let top = Self(rawValue: 1 << 0)
        public static let left = Self(rawValue: 1 << 1)
        public static let bottom = Self(rawValue: 1 << 2)
        public static let right = Self(rawValue: 1 << 3)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// The approximate active direction of the drag gesture.
    public var approximateDirection: Direction {
        var result = Direction()
        
        if translation.height > 0  {
            if predictedEndTranslation.height >= translation.height {
                result.formUnion(.bottom)
            } else {
                result.formUnion(.top)
            }
        } else if translation.height < 0 {
            if predictedEndTranslation.height <= translation.height {
                result.formUnion(.top)
            } else {
                result.formUnion(.bottom)
            }
        }
        
        if translation.width > 0  {
            if predictedEndTranslation.width >= translation.height {
                result.formUnion(.right)
            } else {
                result.formUnion(.left)
            }
        } else if translation.width < 0 {
            if predictedEndTranslation.width <= translation.width {
                result.formUnion(.left)
            } else {
                result.formUnion(.right)
            }
        }
        
        return result
    }
}
