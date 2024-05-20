//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(macOS)

class _PlatformTableCellView<Configuration: _CocoaListConfigurationType>: NSTableCellView {
    let parent: _CocoaList<Configuration>.Coordinator
    
    public var listRepresentable: _CocoaList<Configuration>.Coordinator? {
        parent
    }
    
    private var _frameObserver: NSObjectProtocol?
    private var _lastFrameSize: CGSize? = nil
    private var _stateFlags: Set<_StateFlag> = [.preparedForReuse]
    
    var indexPath: IndexPath?
    var payload: Payload?
    
    var stateFlags: Set<_StateFlag> {
        _stateFlags
    }
        
    override var translatesAutoresizingMaskIntoConstraints: Bool {
        get {
            false
        } set {
            super.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override var fittingSize: NSSize {
        var result = super.fittingSize
        
        if let superview = self.superview, superview.frame.size.isRegularAndNonZero {
            result.width = superview.frame.size.width
        }
        
        if result.height == 0 {
            assertionFailure()
        }
        
        return result
    }
    
    override var intrinsicContentSize: NSSize {
        super.intrinsicContentSize
    }

    override var needsUpdateConstraints: Bool {
        get {
            super.needsUpdateConstraints
        } set {
            //super.needsUpdateConstraints = newValue
        }
    }
    
    private var _contentHostingView: ContentHostingView? {
        didSet {
            if let _contentHostingView {
                if _contentHostingView.superview != nil {
                    assertionFailure()
                }
                
                _contentHostingView.withCriticalScope([.suppressIntrinsicContentSizeInvalidation]) {
                    addSubview(_contentHostingView)
                }
            } else {
                if let oldValue, oldValue.superview != nil {
                    assertionFailure()
                }
            }
        }
    }
        
    var contentHostingView: ContentHostingView {
        get {
            if self._stateFlags.contains(.preparedForReuse) {
                assertionFailure()
            }
            
            let result = _contentHostingView ?? _initializeContentHostingView()
            
            if !(result.superview === self) {
                assert(!result._hostingViewConfigurationFlags.contains(.invisible))
               
                addSubview(result)
            }
            
            return result
        } set {
            _contentHostingView = newValue
        }
    }
    
    var isCellInDisplay: Bool {
        _contentHostingView != nil
    }
    
    init(
        parent: _PlatformTableViewContainer<Configuration>,
        identifier: NSUserInterfaceItemIdentifier
    ) {
        self.parent = parent.coordinator
        
        super.init(frame: .zero)
        
        self.identifier = identifier
        
        if self.parent.configuration.preferences.cell.viewHostingOptions.useAutoLayout {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        isHorizontalContentSizeConstraintActive = false
        isVerticalContentSizeConstraintActive = false
        
        autoresizesSubviews = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidChangeBackingProperties() {
        
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        _fixContentHostingViewSizeIfNeeded()
    }
        
    override func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        if _stateFlags.contains(.isInitializingContentHostingView) {
            guard _contentHostingView == nil else {
                return
            }
        }
        
        super.resizeSubviews(withOldSize: oldSize)
        
        if !(_stateFlags.contains(.isInitializingContentHostingView) || inLiveResize) {
            _contentHostingView?._SwiftUIX_setNeedsLayout()
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        guard !stateFlags.contains(.wasJustPutIntoUse) else {
            return
        }
        
        super.invalidateIntrinsicContentSize()
    }
    
    override func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
        axis == .horizontal
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        if let listRepresentable {
            if listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) ||  (_contentHostingView?.contentHostingViewCoordinator.stateFlags.contains(.payloadDidJustUpdate) ?? false) {
                return nil
            }
        }
        
        return super.hitTest(point)
    }

    override func prepareForReuse() {
        guard self.indexPath != nil && self.payload != nil else {
            assertionFailure()
            
            return
        }
                
        self._stateFlags.remove(.wasJustPutIntoUse)
        self._stateFlags.insert(.preparedForReuse)
        
        _tearDownContentHostingView()
        
        self.indexPath = nil
        self.payload = nil
    }

    deinit {
        _tearDownContentHostingView()
    }
    
    func prepareForUse(
        payload: Payload,
        tableView: NSTableView?
    ) {
        guard self.stateFlags.contains(.preparedForReuse) else {
            assertionFailure()
            
            return
        }
                
        self._stateFlags.remove(.preparedForReuse)
        self._stateFlags.insert(.wasJustPutIntoUse)
        
        DispatchQueue.main.async {
            guard !self._stateFlags.contains(.preparedForReuse) else {
                assertionFailure()

                return
            }
            
            self._stateFlags.remove(.wasJustPutIntoUse)
        }
        
        self.payload = payload
       
        _withoutAppKitOrUIKitAnimation {
            if let contentHostingView = _contentHostingView {
                _updateContentHostingView(contentHostingView, payload: payload)
            } else {
                let contentHostingView = _initializeContentHostingView(tableView: tableView)
                
                _updateContentHostingView(contentHostingView, payload: payload)
            }
            
            _prepareContentHostingViewForUse()
        }
    }

    private func _prepareContentHostingViewForUse() {
        guard let _contentHostingView else {
            return
        }
        
        _contentHostingView._hostingViewConfigurationFlags.remove(.invisible)
    }
    
    private func _updateContentHostingView(
        _ contentHostingView: ContentHostingView,
        payload: Payload
    ) {
        if !parent.configuration.preferences.cell.viewHostingOptions.detachHostingView {
            let preferredSize: CGSize? = OptionalDimensions(intrinsicContentSize: contentHostingView._bestIntrinsicContentSizeEstimate).toCGSize()
            
            if let preferredSize {
                if contentHostingView.frame.size != preferredSize {
                    contentHostingView._overrideSizeForUpdateConstraints = .init(preferredSize)
                }
            }
            
            contentHostingView.payload = payload
        } else {
            contentHostingView.payload = payload
        }
        
        if let _fastRowHeight, let cachedHeight = _contentHostingView?.displayCache._preferredIntrinsicContentSize?.height, cachedHeight != _fastRowHeight {
            contentHostingView.invalidateIntrinsicContentSize()
            
            contentHostingView.needsUpdateConstraints = true
        }
        
        contentHostingView._refreshCocoaHostingView()
    }
        
    /// Refreshes the content hosting view.
    ///
    /// This is typically called when there is no major data update, but the outer SwiftUI context has updated.
    open func refreshCellContent() {
        contentHostingView._refreshCocoaHostingView()
    }
        
    @discardableResult
    private func _initializeContentHostingView(
        tableView: NSTableView? = nil
    ) -> ContentHostingView {
        guard let payload else {
            fatalError()
        }
        
        assert(_contentHostingView == nil)
        
        self._stateFlags.insert(.isInitializingContentHostingView)
        
        defer {
            self._stateFlags.remove(.isInitializingContentHostingView)
        }
        
        let result: ContentHostingView
        
        if let _result = self._expensiveCache?.decacheContentView() {
            let bestSizeEstimate = self._cheapCache?.lastContentSize ?? self.frame.size
            
            result = _result
            
            if !result.frame.size._isInvalidForIntrinsicContentSize, result.frame.size != self.frame.size {
                self.frame.size = result.frame.size
            } else if result.frame.size._isInvalidForIntrinsicContentSize {
                result.frame.size = bestSizeEstimate
            }
            
            self._contentHostingView = result
        } else {
            let bestSizeEstimate = self._cheapCache?.lastContentSize

            result = ContentHostingView(payload: payload, listRepresentable: self.parent)
            
            if let bestSizeEstimate, bestSizeEstimate.isRegularAndNonZero, result.frame.size._isInvalidForIntrinsicContentSize {
                result._overrideSizeForUpdateConstraints = .init(bestSizeEstimate)
            }
                        
            self._contentHostingView = result
        }
        
        assert(result.superview != nil)
        
        return result
    }
    
    private func _fixContentHostingViewSizeIfNeeded() {
        guard let _contentHostingView, _contentHostingView.frame.size.width._isInvalidForIntrinsicContentSize else {
            return
        }
        
        guard !frame.size._isInvalidForIntrinsicContentSize else {
            return
        }
            
        let newSize: CGSize = OptionalDimensions(normalNonZeroDimensionsFrom: _contentHostingView.frame.size).replacingUnspecifiedDimensions(by: frame.size)
        
        if !self.parent.configuration.preferences.cell.viewHostingOptions.detachHostingView {
            if !newSize._isInvalidForIntrinsicContentSize {
                _contentHostingView._overrideSizeForUpdateConstraints = .init(newSize)
            }
        }
    }

    private func _tearDownContentHostingView() {
        guard let _contentHostingView else {
            if _stateFlags.contains(.preparedForReuse) {
                assert(payload == nil)
            }
            
            assertionFailure()
            
            return
        }
                
        _contentHostingView._hostingViewConfigurationFlags.insert(.invisible)

        assert(payload != nil)
        
        if parent.configuration.preferences.cell.viewHostingOptions.detachHostingView {
            _detachContentHostingView()
        }
    }
    
    private func _detachContentHostingView() {
        guard let _contentHostingView else {
            assertionFailure()
            
            return
        }
        
        assert(parent.configuration.preferences.cell.viewHostingOptions.detachHostingView)
        
        _contentHostingView.removeFromSuperview()
     
        self._contentHostingView = nil
        
        self._expensiveCache!.cellContentView = _contentHostingView
    }
}

extension _PlatformTableCellView {
    var _cheapCache: _CocoaListCache<Configuration>.CheapItemCache? {
        guard let payload else {
            return nil
        }
        
        return parent.cache[cheap: payload.itemPath]
    }
    
    var _expensiveCache: _CocoaListCache<Configuration>.ExpensiveItemCache? {
        guard let payload else {
            return nil
        }
        
        return parent.cache[expensive: payload.itemPath]
    }
    
    var _maximumContentViewWidth: CGFloat? {
        var result: CGFloat = frame.width
        
        result -= (enclosingScrollView?.contentInsets.left ?? 0)
        result -= (enclosingScrollView?.contentInsets.right ?? 0)
        
        return result
    }
    
    var _fastRowHeight: CGFloat? {
        guard let indexPath else {
            assertionFailure()
            
            return nil
        }
        
        return parent._fastHeight(for: indexPath)
    }
}

// MARK: - Auxiliary

extension _PlatformTableCellView {
    enum _StateFlag {
        case preparedForReuse
        case wasJustPutIntoUse
        case isInitializingContentHostingView
    }
    
    struct Payload: Identifiable {
        let itemPath: _CocoaListCache<Configuration>.ItemPath
        var item: Configuration.Data.ItemType
        var content: Configuration.ViewProvider.RowContent
        
        var sectionID: _AnyCocoaListSectionID {
            itemPath.section
        }
        
        var itemID: _AnyCocoaListItemID {
            itemPath.item
        }
        
        var id: AnyHashable {
            itemPath
        }
    }
}

#endif
