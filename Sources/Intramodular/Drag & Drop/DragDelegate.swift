//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

/// An interface that you implement to observe a drag operation in a view modified to be draggble.
public protocol DragDelegate {
    func dragBegan(info: DragInfo)
    func dragUpdated(info: DragInfo)
    func dragEnded(info: DragInfo)
}

/// The current state of a drag.
public struct DragInfo {
    public let items: [DragItem]
}

// MARK: - Auxiliary Implementation -

public struct AnyDragDelegate: DragDelegate {
    let dragBeganImpl: (DragInfo) -> ()
    let dragUpdatedImpl: (DragInfo) -> ()
    let dragEndedImpl: (DragInfo) -> ()
    
    public init(
        dragBegan: @escaping (DragInfo) -> (),
        dragUpdated: @escaping (DragInfo) -> (),
        dragEnded: @escaping (DragInfo) -> ()
    ) {
        self.dragBeganImpl = dragBegan
        self.dragUpdatedImpl = dragUpdated
        self.dragEndedImpl = dragEnded
    }
    
    public func dragBegan(info: DragInfo) {
        dragBeganImpl(info)
    }
    
    public func dragUpdated(info: DragInfo) {
        dragUpdatedImpl(info)
    }
    
    public func dragEnded(info: DragInfo) {
        dragEndedImpl(info)
    }
}

#endif
