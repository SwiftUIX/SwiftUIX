//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(macOS)

class _PlatformTableCellView<Configuration: _CocoaListConfigurationType>: NSTableCellView {
    let parent: _CocoaList<Configuration>.Coordinator
    
    private var _frameObserver: NSObjectProtocol?
    private var _lastFrameSize: CGSize? = nil
    private var _stateFlags: Set<_StateFlag> = []
    
    var indexPath: IndexPath?
    var payload: Payload?
    
    var stateFlags: Set<_StateFlag> {
        _stateFlags
    }

    private var _contentHostingView: ContentHostingView? {
        didSet {
            if let oldValue, oldValue.superview != nil {
                oldValue.removeFromSuperview()
            }
            
            if let _contentHostingView {
                _contentHostingView.withCriticalScope([.suppressRelayout]) {
                    addSubview(_contentHostingView)
                }
            }
        }
    }
    
    var contentHostingView: ContentHostingView {
        get {
            let result = _contentHostingView ?? _initializeContentHostingView()
            
            if !(result.superview === self) {
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
        
        self.autoresizesSubviews = false
        self.identifier = identifier
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        _fixContentHostingViewSizeIfNeeded()
    }
    
    private func _fixContentHostingViewSizeIfNeeded() {
        guard let _contentHostingView, _contentHostingView.frame.size.width._isInvalidForIntrinsicContentSize else {
            return
        }
        
        guard !frame.size._isInvalidForIntrinsicContentSize else {
            return
        }
        
        _contentHostingView.frame.size.width = self.frame.size.width
        
        DispatchQueue.main.async {
            guard _contentHostingView.superview != nil else {
                return
            }
            
            assert(_contentHostingView.superview != nil)
            
            _contentHostingView._SwiftUIX_layoutIfNeeded()
        }
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
    
    func prepareForUse(
        payload: Payload,
        tableView: NSTableView?
    ) {
        guard !self._stateFlags.contains(.wasJustPutIntoUse) else {
            return
        }
        
        self._stateFlags.remove(.preparedForReuse)
        self._stateFlags.insert(.wasJustPutIntoUse)
        
        DispatchQueue.main.async {
            guard !self._stateFlags.contains(.preparedForReuse) else {
                return
            }
            
            self._stateFlags.remove(.wasJustPutIntoUse)
        }
        
        self.payload = payload

        if let contentHostingView = _contentHostingView {
            assert(!parent.configuration.preferences.cell.viewHostingOptions.detachHostingView)
            
            _withoutAppKitOrUIKitAnimation {
                if let size = self._cheapCache?.lastContentSize, size != self.frame.size {
                    contentHostingView.frame.size = size
                }
                
                contentHostingView.withCriticalScope([.suppressRelayout]) {
                    contentHostingView.payload = payload
                }
                
                contentHostingView.isHidden = false
            }
        } else {
            _initializeContentHostingView(tableView: tableView)
        }
    }
    
    override func prepareForReuse() {
        guard self.payload != nil || _contentHostingView != nil else {
            return
        }
                
        _contentHostingView?.isHidden = true

        self._stateFlags.remove(.wasJustPutIntoUse)
        self._stateFlags.insert(.preparedForReuse)
        
        _tearDownContentHostingView()
        
        self.indexPath = nil
        self.payload = nil
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
        
        self._stateFlags.insert(.isInitializingContentHostingView)
        
        defer {
            self._stateFlags.remove(.isInitializingContentHostingView)
        }
        
        let result: ContentHostingView
        
        if let _result = self._expensiveCache?.cellContentView as? ContentHostingView {
            result = _result
            
            if result.frame.size != self.frame.size, !result.frame.size._isInvalidForIntrinsicContentSize {
                self.frame.size = result.frame.size
            }
            
            self._contentHostingView = result
        } else {
            result = ContentHostingView(payload: payload, listRepresentable: self.parent)
            
            self._contentHostingView = result
            
            if parent.configuration.preferences.cell.viewHostingOptions.detachHostingView {
                self._expensiveCache?.cellContentView = result
            }
        }
        
        assert(result.superview != nil)
        
        return result
    }
        
    private func _tearDownContentHostingView() {
        guard _contentHostingView != nil else {
            if _stateFlags.contains(.preparedForReuse) {
                assert(payload == nil)
            }
            
            return
        }
        
        assert(payload != nil)
        
        if parent.configuration.preferences.cell.viewHostingOptions.detachHostingView {
            _detachContentHostingView()
        }
    }
    
    private func _detachContentHostingView() {
        assert(parent.configuration.preferences.cell.viewHostingOptions.detachHostingView)
        
        self._contentHostingView?.removeFromSuperview()
        self._contentHostingView = nil
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
    
    var _fastRowHeight: CGFloat? {
        guard let indexPath else {
            assertionFailure()
            
            return nil
        }
        
        return parent._fastHeight(for: indexPath)
    }
}

extension _PlatformTableCellView {
    var _maximumContentViewWidth: CGFloat? {
        frame.width - ((enclosingScrollView?.contentInsets.left ?? 0) + (enclosingScrollView?.contentInsets.right ?? 0))
    }
}

// MARK: - Auxiliary

extension _PlatformTableCellView {
    enum _StateFlag {
        case preparedForReuse
        case wasJustPutIntoUse
        case isInitializingContentHostingView
    }
    
    struct Payload {
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
            return itemPath
        }
    }
}

#endif
