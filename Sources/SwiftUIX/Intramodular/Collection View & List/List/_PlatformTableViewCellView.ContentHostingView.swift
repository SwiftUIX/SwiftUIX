//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import SwiftUI

extension _PlatformTableCellView {
    final class ContentHostingView: _CocoaHostingView<ContentHostingContainer> {
        private var _constraintsWithSuperview: [NSLayoutConstraint]? = nil
        
        private(set) var contentHostingViewCoordinator: ContentHostingViewCoordinator!
        
        public var listRepresentable: _CocoaList<Configuration>.Coordinator {
            contentHostingViewCoordinator.listRepresentable
        }
        
        override var fittingSize: NSSize {
            super.fittingSize
        }
        
        override var intrinsicContentSize: CGSize {
            if contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) {
                if let parent = parent, let cache = self.parent?._cheapCache, let size = cache.lastContentSize {
                    return CGSize(width: parent.frame.size.width, height: size.height)
                }
            }
            
            if let fastHeight = contentHostingViewCoordinator._fastHeight {
                return CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: fastHeight)
            } else {
                return CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
            }
        }
        
        var parent: _PlatformTableCellView? {
            guard let result = superview as? _PlatformTableCellView else {
                return nil
            }
            
            guard !result.stateFlags.contains(.preparedForReuse) else {
                return nil
            }
            
            return result
        }
        
        public var payload: Payload {
            get {
                mainView.payload
            } set {
                let oldValue = mainView.payload
                                
                if newValue.id != oldValue.id {
                    payloadWillUpdate()
                }
                
                mainView.payload = newValue
            }
        }
        
        convenience init(
            payload: Payload,
            listRepresentable: _CocoaList<Configuration>.Coordinator
        ) {
            self.init(
                mainView: .init(
                    coordinator: .init(listRepresentable: listRepresentable),
                    payload: payload
                )
            )
        
            self.contentHostingViewCoordinator = self.mainView.coordinator
            self.contentHostingViewCoordinator.parent = self
            
            _updateSizingOptions(parent: nil)
        }
        
        override func _assembleCocoaHostingView() {
            #if swift(>=5.9)
            if #available(macOS 14.0, *) {
                sceneBridgingOptions = []
            }
            #endif
        }
        
        override func _refreshCocoaHostingView() {
            _updateSizingOptions(parent: parent)
        }
        
        func payloadWillUpdate() {
            /*guard let cache = self.parent?._cheapCache else {
                return
            }
            
            assert(cache.id == payload.itemPath)*/
                                            
            contentHostingViewCoordinator.stateFlags.insert(.payloadDidJustUpdate)
            
            DispatchQueue.main.async {
                self.contentHostingViewCoordinator.stateFlags.remove(.payloadDidJustUpdate)
            }
        }
        
        override func viewWillMove(
            toSuperview newSuperview: NSView?
        ) {
            super.viewWillMove(toSuperview: newSuperview)
            
            if newSuperview == nil {
                if listRepresentable.configuration.preferences.cell.viewHostingOptions.detachHostingView {
                    _tearDownConstraints()
                }
            } else {
                if let lastContentSize = (newSuperview as? _PlatformTableCellView)?._cheapCache?.lastContentSize {
                    if frame.size != lastContentSize {
                        self.frame.size = lastContentSize
                    }
                }
            }
            
            _updateSizingOptions(parent: newSuperview as? _PlatformTableCellView)
        }
                
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            
            if superview != nil {
                _setUpConstraints()
            }
        }
        
        override func setFrameSize(_ newSize: NSSize) {
            guard !newSize.width._isInvalidForIntrinsicContentSize else {
                return
            }
            
            super.setFrameSize(newSize)
            
            _writeToCache(size: newSize)
        }
        
        override func resizeSubviews(
            withOldSize oldSize: NSSize
        ) {
            guard !self.frame.width._isInvalidForIntrinsicContentSize else {
                return
            }
            
            super.resizeSubviews(withOldSize: oldSize)
            
            _writeToCache(size: frame.size)
        }
        
        private func _writeToCache(size: CGSize) {
            guard !contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) else {
                return
            }
            
            if size.isRegularAndNonZero {
                parent?._cheapCache?.lastContentSize = size
            } else {
                parent?._cheapCache?.lastContentSize = nil
            }
        }
        
        override func invalidateIntrinsicContentSize() {
            guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                return
            }
            
            guard !_hostingViewStateFlags.contains(.didJustMoveToSuperview) else {
                return
            }
            
            super.invalidateIntrinsicContentSize()
            
            parent?._cheapCache?.lastContentSize = nil
        }
        
        private func _updateSizingOptions(parent: _PlatformTableCellView?) {
            guard let parent = parent else {
                if #available(macOS 13.0, *) {
                    _assignIfNotEqual([.intrinsicContentSize], to: \.sizingOptions)
                }

                return
            }
            
            guard !_hostingViewStateFlags.contains(.didJustMoveToSuperview) else {
                return
            }
            
            _assignIfNotEqual(false, to: \.translatesAutoresizingMaskIntoConstraints)
            
            if let height = parent._fastRowHeight {
                if #available(macOS 13.0, *) {
                    _assignIfNotEqual([], to: \.sizingOptions)
                }
                
                let didUpdate = _assignIfNotEqual(height, to: \.contentHostingViewCoordinator._fastHeight)
                
                if didUpdate {
                    self.invalidateIntrinsicContentSize()
                }
                
                _assignIfNotEqual(height, to: \.frame.size.height)
            } else {
                if #available(macOS 13.0, *) {
                    _assignIfNotEqual([.intrinsicContentSize], to: \.sizingOptions)
                }
            }
        }
    }
}

extension _PlatformTableCellView.ContentHostingView {
    fileprivate func _setUpConstraints() {
        guard let superview else {
            return
        }
        
        guard self._constraintsWithSuperview == nil else {
            return
        }
        
        let constraints = [
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self._constraintsWithSuperview = constraints
    }
    
    fileprivate func _tearDownConstraints() {
        if let currentConstraints = self._constraintsWithSuperview {
            NSLayoutConstraint.deactivate(currentConstraints)
            
            self._constraintsWithSuperview = nil
        }
    }
}

// MARK: - Auxiliary

extension _PlatformTableCellView {
    struct ContentHostingContainer: View {
        @ObservedObject var coordinator: ContentHostingViewCoordinator
        
        var payload: Payload
        
        @State private var didAppear: Bool = false
        
        private var disableAnimations: Bool {
            guard didAppear else {
                return true
            }
            
            if coordinator.listRepresentable.tableView?.inLiveResize == true {
                return true
            }
            
            if coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                return true
            }
            
            return false
        }
        
        var width: CGFloat? {
            guard let parent = coordinator.parent else {
                return nil
            }
            
            if !didAppear {
                return parent.frame.width
            }
            
            if coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                return parent.frame.width
            }
            
            return nil
        }
        
        var height: CGFloat? {
            if let height = coordinator._fastHeight {
                return height
            }
            
            if coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                return coordinator.parent?.parent?._cheapCache?.lastContentSize?.height
            }
            
            return nil
        }

        var body: some View {
            payload.content
                .frame(width: width, height: height)
                .onAppear {
                    if !didAppear {
                        didAppear = true
                    }
                }
                .transaction { transaction in
                    transaction.disablesAnimations = disableAnimations
                }
                ._geometryGroup(.if(.available))
        }
    }
    
    final class ContentHostingViewCoordinator: ObservableObject {
        enum StateFlag {
            case firstRenderComplete
            case payloadDidJustUpdate
        }
        
        @Published var stateFlags: Set<StateFlag> = []
        
        fileprivate(set) weak var parent: ContentHostingView?
        
        let listRepresentable: _CocoaList<Configuration>.Coordinator
        
        var _fastHeight: CGFloat?
        
        init(listRepresentable: _CocoaList<Configuration>.Coordinator) {
            self.listRepresentable = listRepresentable
        }
    }
}

#endif
