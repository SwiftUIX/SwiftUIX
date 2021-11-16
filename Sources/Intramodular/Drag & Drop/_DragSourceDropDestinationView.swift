//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS) || targetEnvironment(macCatalyst)

struct _DragSourceDropDestinationView<
    Content: View,
    LiftPreview: View,
    CancelPreview: View
>: UIViewControllerRepresentable {
    typealias UIViewControllerType = CocoaHostingController<Content>
    
    let content: Content
    
    let dragDelegate: DragDelegate?
    let dragItems: (() -> [DragItem])?
    let liftPreview: (DragItem) -> LiftPreview
    let cancelPreview: (DragItem) -> CancelPreview
    
    var validateDrop: (([DragItem]) -> Bool)? = nil
    var onDrop: (([DragItem]) -> Void)? = nil
    
    init(
        content: Content,
        dragDelegate: DragDelegate?,
        dragItems: (() -> [DragItem])?,
        liftPreview: @escaping (DragItem) -> LiftPreview,
        cancelPreview: @escaping (DragItem) -> CancelPreview,
        validateDrop: (([DragItem]) -> Bool)?,
        onDrop: (([DragItem]) -> Void)?
    ) {
        self.content = content
        self.dragDelegate = dragDelegate
        self.dragItems = dragItems
        self.liftPreview = liftPreview
        self.cancelPreview = cancelPreview
        self.validateDrop = validateDrop
        self.onDrop = onDrop
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIViewControllerType(mainView: content)
        
        context.coordinator.viewController = viewController
        context.coordinator.base = self
        
        viewController.view.backgroundColor = nil
                
        if onDrop != nil {
            viewController.view.addInteraction(context.coordinator.dropInteraction)
        }

        return viewController
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.mainView = content
        
        context.coordinator.viewController = viewController
        context.coordinator.base = self
        
        if dragItems != nil {
            context.coordinator.dragInteraction.isEnabled = true
            
            if context.coordinator.dragInteraction.view == nil {
                viewController.view.addInteraction(context.coordinator.dragInteraction)
            }
            
            if let longPressRecognizer = viewController.view.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).filter({ NSStringFromClass(type(of: $0)).contains("Drag") }).first {
                if longPressRecognizer.minimumPressDuration != 0 {
                    longPressRecognizer.minimumPressDuration = 0
                }
            }
        }
    }
    
    class Coordinator: NSObject, UIDragInteractionDelegate, UIDropInteractionDelegate {
        enum _DragPreviewType {
            case lift
            case cancel
        }
        
        class DragPreviewHostingView: UIHostingView<AnyView> {
            override var alpha: CGFloat {
                get {
                    super.alpha
                } set {
                    super.alpha = 1.0
                }
            }
        }
        
        var base: _DragSourceDropDestinationView
        
        init(base: _DragSourceDropDestinationView) {
            self.base = base
        }
        
        weak var viewController: UIViewControllerType?
        
        lazy var dragInteraction = UIDragInteraction(delegate: self)
        lazy var dropInteraction = UIDropInteraction(delegate: self)
        
        var defaultDragLiftPreviewView: UIView?
        var defaultDragCancelPreviewView: UIView?
        
        // MARK: - UIDragInteractionDelegate -
        
        func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
            (base.dragItems?() ?? []).map(UIDragItem.init)
        }
        
        func dragInteraction(
            _ interaction: UIDragInteraction,
            previewForLifting item: UIDragItem,
            session: UIDragSession
        ) -> UITargetedDragPreview? {
            return dragPreview(ofType: .lift, forItem: item)
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
            
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
            base.dragDelegate?.dragBegan(info: .init(interaction: interaction, session: session))
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
            if let viewController = viewController, viewController.view.alpha != 0.0 {
                viewController.view.alpha = 0.0
            }
            
            base.dragDelegate?.dragUpdated(info: .init(interaction: interaction, session: session))
        }
        
        func dragInteraction(
            _ interaction: UIDragInteraction,
            previewForCancelling item: UIDragItem,
            withDefault defaultPreview: UITargetedDragPreview
        ) -> UITargetedDragPreview? {
            if CancelPreview.self == EmptyView.self {
                return defaultPreview
            } else {
                return dragPreview(ofType: .cancel, forItem: item)
            }
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
            animator.addCompletion { _ in
                if let viewController = self.viewController {
                    viewController.view.alpha = 1.0
                }
            }
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, willEndWith operation: UIDropOperation) {
            
        }
        
        func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
            self.base.dragDelegate?.dragEnded(info: .init(interaction: interaction, session: session))
            
            self.viewController?.view.alpha = 1.0
            
            defaultDragLiftPreviewView?.removeFromSuperview()
            defaultDragCancelPreviewView?.removeFromSuperview()
        }
        
        private func dragPreview(
            ofType type: _DragPreviewType,
            forItem item: UIDragItem
        ) -> UITargetedDragPreview? {
            guard let viewController = viewController else {
                return nil
            }
            
            let previewView: UIView
            
            switch type {
                case .lift: do {
                    if let defaultDragLiftPreviewView = defaultDragLiftPreviewView {
                        previewView = defaultDragLiftPreviewView
                    } else  {
                        previewView = DragPreviewHostingView(
                            rootView: LiftPreview.self == EmptyView.self
                                ? base.content.eraseToAnyView()
                                : base.liftPreview(.init(item)).eraseToAnyView()
                        )
                    }
                    
                    defaultDragLiftPreviewView = previewView
                }
                case .cancel: do {
                    if let defaultDragCancelPreviewView = defaultDragCancelPreviewView {
                        previewView = defaultDragCancelPreviewView
                    } else {
                        previewView = DragPreviewHostingView(
                            rootView: CancelPreview.self == EmptyView.self
                                ? base.content.eraseToAnyView()
                                : base.cancelPreview(.init(item)).eraseToAnyView()
                        )
                    }
                    
                    defaultDragCancelPreviewView = previewView
                }
            }
            
            previewView.sizeToFit()
            
            let parameters = UIDragPreviewParameters()
            parameters.backgroundColor = UIColor.clear
            parameters.visiblePath = UIBezierPath(rect: previewView.bounds)
            
            if #available(iOS 14.0, *) {
                parameters.shadowPath = UIBezierPath()
            }
            
            let preview = UITargetedDragPreview(
                view: previewView,
                parameters: parameters,
                target: .init(
                    container: viewController.view,
                    center: viewController.view.center
                )
            )
            
            return preview
        }
        
        // MARK: - UIDropInteractionDelegate -
        
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            true
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            if let canDrop = base.validateDrop?(session.items.map(DragItem.init)), canDrop {
                return .init(operation: .move)
            }
            
            return UIDropProposal(operation: .cancel)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            base.onDrop?(session.items.map(DragItem.init))
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
            animator.addAnimations {
                if let viewController = self.viewController {
                    viewController.view.alpha = 1.0
                }
            }
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
            
        }
    }
    
    public static func dismantleUIViewController(
        _ uiViewController: UIViewControllerType,
        coordinator: Coordinator
    ) {
        uiViewController.view.alpha = 1.0
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(base: self)
    }
}

extension View {
    public func _onDrag(
        delegate: DragDelegate? = nil,
        _ items: @escaping () -> [DragItem]
    ) -> some View {
        _DragSourceDropDestinationView(
            content: self,
            dragDelegate: delegate,
            dragItems: items,
            liftPreview: { _ in EmptyView() },
            cancelPreview: { _ in EmptyView() },
            validateDrop: nil,
            onDrop: nil
        )
    }
    
    public func _onDrop<Item>(
        of item: Item.Type,
        perform onDrop: @escaping (Item) -> (),
        validate: @escaping (Item) -> Bool
    ) -> some View {
        _DragSourceDropDestinationView(
            content: self,
            dragDelegate: nil,
            dragItems: nil,
            liftPreview: { _ in EmptyView() },
            cancelPreview: { _ in EmptyView() },
            validateDrop: { items in
                guard items.count == 1 else {
                    return false
                }
                
                guard let item = items.first?.base as? Item else {
                    return false
                }
                
                return validate(item)
            },
            onDrop: { items in
                guard items.count == 1 else {
                    return
                }
                
                guard let item = items.first?.base as? Item else {
                    return
                }
                
                onDrop(item)
            }
        )
    }
}

// MARK: - Helpers -

extension DragInfo {
	public init(interaction: UIDragInteraction, session: UIDragSession) {
        self.init(items: session.items.map(DragItem.init))
    }
}

#endif
