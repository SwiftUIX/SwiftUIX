//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(visionOS)

import Combine
import SwiftUI
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@_documentation(visibility: internal)
public class AnyFileDropDelegate: DropDelegate, ObservableObject {
    public class DroppedItem: ObservableObject {
        weak var owner: AnyFileDropDelegate?
        
        public var isLoading: Bool?
        public var loadedURL: URL?
        public var bookmarkData: Data?
        
        var _isInvalid: Bool {
            if isLoading == false && loadedURL == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    private let onDrag: ([DroppedItem]) -> Void = { _ in }
    private let onDrop: ([DroppedItem]) -> Void
    
    public init(
        onDrop: @escaping ([DroppedItem]) -> Void
    ) {
        self.onDrop = onDrop
    }
    
    fileprivate var previousDropInteractions: [DropInteraction] = []
    fileprivate var currentDropInteraction: DropInteraction?
    
    var dropInteraction: DropInteraction {
        if let result = self.currentDropInteraction {
            return result
        } else {
            let result = DropInteraction(onDrop: onDrop)
            
            self.currentDropInteraction = result
            
            return result
        }
    }
    
    public func validateDrop(
        info: DropInfo
    ) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
    }
    
    public func dropEntered(
        info: DropInfo
    ) {
        let dropInteraction = self.dropInteraction
        
        dropInteraction.droppedItems = info.itemProviders(for: [.fileURL]).map { _ in DroppedItem() }
        
        for (index, itemProvider) in info.itemProviders(for: [.fileURL]).enumerated() {
            dropInteraction.droppedItems?[index].isLoading = true
            
            itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] (urlData, error) in
                guard let self = self else {
                    return
                }
                
                Task { @MainActor in
                    if let urlData = urlData as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        self.dropInteraction.droppedItems?[index].loadedURL = url
                    }
                    
                    dropInteraction.droppedItems?[index].isLoading = false
                }
            }
        }
    }
    
    public func dropUpdated(
        info: DropInfo
    ) -> DropProposal? {
        if dropInteraction.droppedItems.map({ $0.contains(where: { !$0._isInvalid }) }) ?? true {
            return DropProposal(operation: .copy)
        } else {
            return DropProposal(operation: .forbidden)
        }
    }
    
    public func dropExited(info: DropInfo) {

    }
    
    public func performDrop(info: DropInfo) -> Bool {
        _endDropInteraction()
        
        return true
    }
    
    private func _endDropInteraction() {
        if let currentDropInteraction {
            currentDropInteraction.attemptToFlushDroppedItems()
            
            self.currentDropInteraction = nil
            self.previousDropInteractions.append(currentDropInteraction)
        }
    }
}

@available(macOS 11.0, iOS 14.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension AnyFileDropDelegate {
    @MainActor
    class DropInteraction {
        let onDrop: ([DroppedItem]) -> Void
        
        var droppedItems: [DroppedItem]?
        var droppedItemsWereConsumed: Bool = false
        
        init(onDrop: @escaping ([DroppedItem]) -> Void) {
            self.onDrop = onDrop
        }
        
        func attemptToFlushDroppedItems() {
            guard let droppedItems, !droppedItems.isEmpty else {
                return
            }
            
            guard !droppedItems.contains(where: { $0.loadedURL == nil }) else {
                return
            }
            
            self.onDrop(droppedItems)
            
            self.droppedItemsWereConsumed = true
        }
    }
}

@available(macOS 11.0, iOS 14.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func onFileDrop(
        delegate: AnyFileDropDelegate
    ) -> some View {
        self.onDrop(of: [.fileURL], delegate: delegate)
    }
}

#endif
