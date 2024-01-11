//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import SwiftUI

extension _PlatformTableCellView {
    final class ContentHostingView: _CocoaHostingView<ContentHostingContainer> {
        public struct DisplayAttributesCache {
            var _preferredIntrinsicContentSize: OptionalDimensions? = nil
        }
        
        var displayCache: DisplayAttributesCache {
            get {
                parent?._cheapCache?.displayAttributes ?? .init()
            } set {
                parent?._cheapCache?.displayAttributes = newValue
            }
        }
        
        var _constraintsWithSuperview: [NSLayoutConstraint]? = nil
        
        private(set) var contentHostingViewCoordinator: ContentHostingViewCoordinator!
        
        public var listRepresentable: _CocoaList<Configuration>.Coordinator {
            contentHostingViewCoordinator.listRepresentable
        }
        
        override var fittingSize: NSSize {
            if let size = OptionalDimensions(intrinsicContentSize: _bestIntrinsicContentSizeEstimate).toCGSize() {
                return size
            }
            
            return super.fittingSize
        }
        
        var _preferredIntrinsicContentSize: OptionalDimensions {
            if let fastRowHeight = parent?._fastRowHeight {
                return OptionalDimensions(width: nil, height: fastRowHeight)
            } else {
                return nil
            }
        }
        
        var _bestIntrinsicContentSizeEstimate: CGSize {
            var result = parent?._cheapCache?.lastContentSize ?? CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: AppKitOrUIKitView.noIntrinsicMetric)
            
            if let parent {
                if parent.frame.size.isRegularAndNonZero {
                    result.width = parent.frame.size.width
                }
                
                if let height = parent._fastRowHeight {
                    result.height = height
                }
            }
            
            return result
        }
        
        override var intrinsicContentSize: CGSize {
            guard let tableView = parent?.superview else {
                return CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: AppKitOrUIKitView.noIntrinsicMetric)
            }
            
            if contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) {
                return _bestIntrinsicContentSizeEstimate
            }
            
            return CGSize(
                width: _preferredIntrinsicContentSize.width ?? tableView.frame.size.width,
                height: _preferredIntrinsicContentSize.height ?? super.intrinsicContentSize.height
            )
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
                payloadWillUpdate()
                
                mainView.payload = newValue
                
                payloadDidUpdate()
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
            guard !contentHostingViewCoordinator.isPendingReuse else {
                return
            }
            
            _updateSizingOptions(parent: parent)
            
            if
                let existing = displayCache._preferredIntrinsicContentSize,
                let newHeight = _preferredIntrinsicContentSize.height,
                existing.height != newHeight
            {
                frame.size.height = newHeight
                
                _writeToCache(size: frame.size)
                
                invalidateIntrinsicContentSize()
                
                _reportAsInvalidatedToListRepresentable()
                
                contentHostingViewCoordinator.stateFlags.insert(.dirtySize)
                
                DispatchQueue.main.async {
                    withoutAnimation {
                        self.contentHostingViewCoordinator.objectWillChange.send()
                    }
                }
            }
            
            displayCache._preferredIntrinsicContentSize = _preferredIntrinsicContentSize
        }
        
        func payloadWillUpdate() {
            if contentHostingViewCoordinator.stateFlags.contains(.firstRenderComplete) {
                contentHostingViewCoordinator.stateFlags.insert(.hasBeenReused)
                contentHostingViewCoordinator.stateFlags.insert(.payloadDidJustUpdate)
                
                DispatchQueue.main.async {
                    withoutAnimation {
                        self.contentHostingViewCoordinator.objectWillChange.send()
                    }
                    
                    self.contentHostingViewCoordinator.stateFlags.remove(.payloadDidJustUpdate)
                }
            }
        }
        
        func payloadDidUpdate() {
            _refreshCocoaHostingView()
        }
        
        override func viewWillMove(
            toSuperview newSuperview: NSView?
        ) {
            if newSuperview != nil {
                assert(!contentHostingViewCoordinator.stateFlags.contains(.isStoredInCache))
            }
            
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
            
            DispatchQueue.main.async {
                self.contentHostingViewCoordinator.stateFlags.insert(.firstRenderComplete)
            }
        }
        
        override func setFrameSize(_ newSize: NSSize) {
            super.setFrameSize(newSize)
            
            _writeToCache(size: newSize)
        }
        
        override func resizeSubviews(
            withOldSize oldSize: NSSize
        ) {
            super.resizeSubviews(withOldSize: oldSize)
            
            _writeToCache(size: frame.size)
        }
        
        override var needsUpdateConstraints: Bool {
            get {
                super.needsUpdateConstraints
            } set {
                super.needsUpdateConstraints = newValue
            }
        }
        
        override func updateConstraintsForSubtreeIfNeeded() {
            guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                return
            }
            
            super.updateConstraintsForSubtreeIfNeeded()
        }
        
        override func updateConstraints() {
            super.updateConstraints()
        }
        
        override func invalidateIntrinsicContentSize() {
            if !contentHostingViewCoordinator.stateFlags.contains(.dirtySize) {
                if contentHostingViewCoordinator.stateFlags.contains(.firstRenderComplete) {
                    guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                        return
                    }
                } else if _hostingViewStateFlags.contains(.didJustMoveToSuperview) {
                    if !self.frame.size._isInvalidForIntrinsicContentSize {
                        return
                    }
                }
            }
            
            contentHostingViewCoordinator.stateFlags.remove(.dirtySize)
            
            super.invalidateIntrinsicContentSize()
            
            if let parent {
                if let size = OptionalDimensions(intrinsicContentSize: self.intrinsicContentSize).toCGSize() {
                    parent._cheapCache?.lastContentSize = size
                } else {
                    parent._cheapCache?.lastContentSize = nil
                    
                    listRepresentable.invalidationContext.indexes.insert(parent.indexPath!.item)
                }
            }
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
                
                if height == 0 {
                    _assignIfNotEqual(height, to: \.frame.size.height)
                }
            } else {
                if #available(macOS 13.0, *) {
                    _assignIfNotEqual([.intrinsicContentSize], to: \.sizingOptions)
                }
            }
        }
        
        deinit {
            self._tearDownConstraints()
        }
    }
}

extension _PlatformTableCellView.ContentHostingView {
    func _reportAsInvalidatedToListRepresentable() {
        guard let parent else {
            assertionFailure()
            
            return
        }
        
        listRepresentable.invalidationContext.indexes.insert(parent.indexPath!.item)
    }
    
    private func _writeToCache(size: CGSize) {
        guard
            let parent = parent,
            let cache = parent._cheapCache, !contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate)
        else {
            return
        }
        
        guard !contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) else {
            return
        }
        
        var size = size
        
        size = _preferredIntrinsicContentSize.replacingUnspecifiedDimensions(by: size)
        
        if size.isRegularAndNonZero {
            let last = cache.lastContentSize
            
            if cache.lastContentSize != size {
                cache.lastContentSize = size
            }
            
            guard !_hostingViewStateFlags.contains(.didJustMoveToSuperview) else {
                return
            }
            
            if last != nil, last != cache.lastContentSize {
                listRepresentable.invalidationContext.indexes.insert(parent.indexPath!.item)
            }
        } else {
            cache.lastContentSize = nil
        }
    }
    
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
        guard let currentConstraints = self._constraintsWithSuperview else {
            return
        }
        
        NSLayoutConstraint.deactivate(currentConstraints)
        
        removeConstraints(currentConstraints)
        
        self._constraintsWithSuperview = nil
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
        
        private var _width: CGFloat? {
            guard let parent = coordinator.parent else {
                return nil
            }
            
            if !didAppear || coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                if let width = OptionalDimensions(intrinsicContentSize: parent._bestIntrinsicContentSizeEstimate).width {
                    return width
                } else if parent.frame.size.width.isNormal {
                    return parent.frame.size.width
                }
            }
            
            return nil
        }
        
        private var _height: CGFloat? {
            guard let parent = coordinator.parent else {
                return nil
            }
            
            let firstRenderComplete = coordinator.stateFlags.contains(.firstRenderComplete)
            
            if !firstRenderComplete {
                guard !parent._hostingViewStateFlags.contains(.didJustMoveToSuperview) else {
                    return nil
                }
            }
            
            if !didAppear || coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                if let result = OptionalDimensions(intrinsicContentSize: parent._bestIntrinsicContentSizeEstimate).height {
                    return result
                } else {
                    return nil
                }
            }
            
            return nil
        }
        
        private var width: CGFloat? {
            guard let _width else {
                return nil
            }
            
            assert(_width > 0)
            
            return _width
        }
        
        private var height: CGFloat? {
            guard let _height else {
                return nil
            }
            
            assert(_height > 0)
            
            return _height
        }
        
        var body: some View {
            payload.content
                .onAppear {
                    if !didAppear {
                        withoutAnimation {
                            didAppear = true
                        }
                    }
                }
                .onDisappear {
                    if didAppear {
                        withoutAnimation {
                            didAppear = false
                        }
                    }
                }
                .transaction { transaction in
                    transaction.disablesAnimations = disableAnimations
                }
                ._geometryGroup(.if(.available))
                .frame(width: width, height: height)
        }
    }
    
    final class ContentHostingViewCoordinator: ObservableObject {
        enum StateFlag {
            case firstRenderComplete
            case payloadDidJustUpdate
            case hasBeenReused
            case isStoredInCache
            case dirtySize
        }
        
        var stateFlags: Set<StateFlag> = []
        
        var isPendingReuse: Bool {
            stateFlags.contains(.isStoredInCache) || !stateFlags.contains(.firstRenderComplete)
        }
        
        fileprivate(set) weak var parent: ContentHostingView?
        
        let listRepresentable: _CocoaList<Configuration>.Coordinator
        
        init(listRepresentable: _CocoaList<Configuration>.Coordinator) {
            self.listRepresentable = listRepresentable
        }
    }
}

#endif
