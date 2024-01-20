//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import SwiftUI

extension _PlatformTableCellView {
    final class ContentHostingView: _CocoaHostingView<ContentHostingContainer> {
        override static var requiresConstraintBasedLayout: Bool {
            true
        }

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
        
        public var listRepresentable: _CocoaList<Configuration>.Coordinator? {
            contentHostingViewCoordinator?.listRepresentable
        }
        
        override var needsUpdateConstraints: Bool {
            get {
                super.needsUpdateConstraints
            } set {
                guard let listRepresentable else {
                    return
                }
                
                guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                    return
                }
                
                super.needsUpdateConstraints = newValue
            }
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
            guard let tableView = parent?.superview?.superview ?? parent?.superview else {
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
                _overrideSizeForUpdateConstraints.height = newHeight
                needsUpdateConstraints = true
                
                _writeToCache(size: frame.size)
                
                _reportAsInvalidatedToListRepresentable()
                
                contentHostingViewCoordinator.stateFlags.insert(.dirtySize)
            }
            
            displayCache._preferredIntrinsicContentSize = _preferredIntrinsicContentSize
        }
        
        func payloadWillUpdate() {
            if contentHostingViewCoordinator.stateFlags.contains(.firstRenderComplete) {
                contentHostingViewCoordinator.stateFlags.insert(.hasBeenReused)
                contentHostingViewCoordinator.stateFlags.insert(.payloadDidJustUpdate)
                
                DispatchQueue.main.async {
                    // self.contentHostingViewCoordinator.objectWillChange.send()
                    self.contentHostingViewCoordinator.stateFlags.remove(.payloadDidJustUpdate)
                }
            }
        }
        
        override func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
            axis == .horizontal
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            if let listRepresentable {
                if listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) || contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) {
                    return nil
                }
            }
            
            return super.hitTest(point)
        }
        
        func payloadDidUpdate() {
            
        }
        
        override func viewWillMove(
            toSuperview newSuperview: NSView?
        ) {
            if newSuperview != nil {
                assert(!contentHostingViewCoordinator.stateFlags.contains(.isStoredInCache))
            }
            
            super.viewWillMove(toSuperview: newSuperview)
            
            guard let listRepresentable = listRepresentable else {
                assertionFailure()
                
                return
            }
            
            if newSuperview == nil {
                if listRepresentable.configuration.preferences.cell.viewHostingOptions.detachHostingView {
                    _tearDownConstraints()
                }
            } else {
                if let lastContentSize = (newSuperview as? _PlatformTableCellView)?._cheapCache?.lastContentSize {
                    _overrideSizeForUpdateConstraints = .init(lastContentSize)
                }
            }
            
            if newSuperview != nil {
                _updateSizingOptions(parent: newSuperview as? _PlatformTableCellView)
            }
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
        
        override func updateConstraintsForSubtreeIfNeeded() {
            guard let listRepresentable else {
                return
            }
            
            guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                return
            }
            
            super.updateConstraintsForSubtreeIfNeeded()
        }
        
        override func updateConstraints() {
            super.updateConstraints()
        }
        
        override func invalidateIntrinsicContentSize() {
            guard let listRepresentable else {
                return
            }
            
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
            
            guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
                return
            }
            
            super.invalidateIntrinsicContentSize()
            
            if let parent {
                if let size = OptionalDimensions(intrinsicContentSize: self.intrinsicContentSize).toCGSize() {
                    parent._cheapCache?.lastContentSize = size
                } else {
                    parent._cheapCache?.lastContentSize = nil
                    
                    if !_hostingViewStateFlags.contains(.didJustMoveToSuperview) {
                        listRepresentable.invalidationContext.indexes.insert(parent.indexPath!.item)
                    }
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
        guard let listRepresentable, let parent else {
            assertionFailure()
            
            return
        }
        
        listRepresentable.invalidationContext.indexes.insert(parent.indexPath!.item)
    }
    
    private func _writeToCache(size: CGSize) {
        guard let listRepresentable else {
            return
        }
        
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
        guard let listRepresentable, listRepresentable.configuration.preferences.cell.viewHostingOptions.useAutoLayout else {
            return
        }
        
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
        guard let listRepresentable else {
            return
        }
        
        guard listRepresentable.configuration.preferences.cell.viewHostingOptions.useAutoLayout else {
            return
        }
        
        guard let currentConstraints = self._constraintsWithSuperview else {
            return
        }
        
        NSLayoutConstraint.deactivate(currentConstraints)
        
        self._constraintsWithSuperview = nil
    }
}

// MARK: - Auxiliary

extension _PlatformTableCellView {
    struct ContentHostingContainer: View {
        @ObservedObject var coordinator: ContentHostingViewCoordinator
        
        var payload: Payload
        
        @ViewStorage private var didAppear: Bool = false
        @ViewStorage private var sustainFrameOverride: Bool = false

        private var disableAnimations: Bool {
            guard didAppear else {
                return true
            }
            
            if coordinator.listRepresentable?.tableView?.inLiveResize == true {
                return true
            }
            
            if coordinator.stateFlags.contains(.payloadDidJustUpdate) {
                return true
            }
            
            return false
        }
        
        private var _shouldOverrideFrame: Bool {
            guard let parent = coordinator.parent else {
                return false
            }
            
            let firstRenderComplete = coordinator.stateFlags.contains(.firstRenderComplete)
            
            if !firstRenderComplete {
                guard !parent._hostingViewStateFlags.contains(.didJustMoveToSuperview) else {
                    return false
                }
            }
            
            return true
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
                                    
            if coordinator.stateFlags.contains(.payloadDidJustUpdate) {
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

            let _shouldOverrideFrame = self._shouldOverrideFrame
            
            if sustainFrameOverride && !_shouldOverrideFrame {
                return _height
            }
            
            guard _shouldOverrideFrame else {
                return nil
            }
            
            return _height
        }
        
        var body: some View {
            _UnaryViewAdaptor(
                payload.content
                    .onAppear {
                        if !didAppear {
                            didAppear = true
                        }
                    }
                    .transaction { transaction in
                        transaction.disableAnimations()
                    }
                    ._geometryGroup(.if(.available))
                    .frame(width: width, height: height)
                    .onChange(of: _shouldOverrideFrame) { should in
                        if should {
                            sustainFrameOverride = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                                sustainFrameOverride = false
                            }
                        }
                    }
            )
            .id(payload.id)
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
        
        weak var listRepresentable: _CocoaList<Configuration>.Coordinator?
        
        init(listRepresentable: _CocoaList<Configuration>.Coordinator) {
            self.listRepresentable = listRepresentable
        }
    }
}

#endif
