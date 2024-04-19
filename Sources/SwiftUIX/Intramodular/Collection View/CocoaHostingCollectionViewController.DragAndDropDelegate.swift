//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension CocoaHostingCollectionViewController {
    #if !os(tvOS)
    class DragAndDropDelegate: NSObject, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
        unowned let parent: CocoaHostingCollectionViewController
        
        init(parent: CocoaHostingCollectionViewController) {
            self.parent = parent
        }
        
        // MARK: - UICollectionViewDragDelegate
        
        func collectionView(
            _ collectionView: UICollectionView,
            itemsForBeginning session: UIDragSession,
            at indexPath: IndexPath
        ) -> [UIDragItem] {
            if let dragItems = parent.cache.preferences(forContentAt: indexPath).wrappedValue?.dragItems {
                return dragItems.map(UIDragItem.init)
            }
            
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            dragPreviewParametersForItemAt indexPath: IndexPath
        ) -> UIDragPreviewParameters? {
            .init()
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            dragSessionWillBegin session: UIDragSession
        ) {
            parent.configuration.isDragActive?.wrappedValue = true
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            dragSessionDidEnd session: UIDragSession
        ) {
            parent.configuration.isDragActive?.wrappedValue = false
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            dragSessionAllowsMoveOperation session: UIDragSession
        ) -> Bool {
            true
        }
        
        // MARK: - UICollectionViewDropDelegate
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            performDropWith coordinator: UICollectionViewDropCoordinator
        ) {
            guard !coordinator.items.isEmpty else {
                return
            }
            
            if coordinator.items.count == 1, let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath, let onMove = parent._dynamicViewContentTraitValues.onMove {
                if var destinationIndexPath = coordinator.destinationIndexPath {
                    parent.cache.invalidateContent(at: sourceIndexPath)
                    parent.cache.invalidateContent(at: destinationIndexPath)

                    if sourceIndexPath.item < destinationIndexPath.item {
                        destinationIndexPath.item += 1
                    }
                    
                    onMove(
                        IndexSet([sourceIndexPath.item]),
                        destinationIndexPath.item
                    )
                }
            } else if let dropDelegate = parent._dynamicViewContentTraitValues.collectionViewDropDelegate {
                let success = dropDelegate.performDrop(info: .init(dragItems: coordinator.items.map({ DragItem($0.dragItem) }), destination: coordinator.destinationIndexPath?.item)) // FIXME: Sectioned drops are currently not accounted for.
                
                if success, let destinationIndexPath = coordinator.destinationIndexPath {
                    for item in coordinator.items {
                        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    }
                }
            } else if let destinationIndexPath = coordinator.destinationIndexPath, let onDrop = parent._dynamicViewContentTraitValues.onDrop {
                onDrop(coordinator.items.map({ DragItem($0.dragItem) }), destinationIndexPath.item)
            }
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidUpdate session: UIDropSession,
            withDestinationIndexPath destinationIndexPath: IndexPath?
        ) -> UICollectionViewDropProposal {
            if session.localDragSession == nil {
                return .init(operation: .cancel, intent: .unspecified)
            }
            
            if collectionView.hasActiveDrag {
                return .init(operation: .move, intent: .insertAtDestinationIndexPath)
            } else if let dropDelegate = parent._dynamicViewContentTraitValues.collectionViewDropDelegate {
                // FIXME: Sectioned drops are currently not accounted for.
                if #available(iOS 13.4, *) {
                    if let proposal = dropDelegate.dropUpdated(info: .init(dragItems: session.items.map(DragItem.init), destination: destinationIndexPath?.item)) {
                        return .init(operation: .init(proposal.operation), intent: .insertAtDestinationIndexPath)
                    }
                }
            }
            
            return .init(operation: .cancel)
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidEnd session: UIDropSession
        ) {
            
        }
    }
    #endif
}

@available(tvOS, unavailable)
extension UIDropOperation {
    @available(iOS 13.4, *)
    @available(tvOS, unavailable)
    init(_ dropOperation: DropOperation) {
        switch dropOperation {
            case .cancel:
                self = .cancel
            case .forbidden:
                self = .forbidden
            case .copy:
                self = .copy
            case .move:
                self = .move
            @unknown default:
                self = .forbidden
        }
    }
}

#endif
