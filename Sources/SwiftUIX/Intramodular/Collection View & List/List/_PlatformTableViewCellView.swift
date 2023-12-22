//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(macOS)

class _PlatformTableCellView<Configuration: _CocoaListConfigurationType>: NSTableCellView {
    weak var parent: _PlatformTableViewContainer<Configuration>?

    private var _frameObserver: NSObjectProtocol?
    private var _lastFrameSize: CGSize? = nil
    private var _stateFlags: Set<_StateFlag> = []
        
    var indexPath: IndexPath?
    var _payload: Payload? {
        didSet {
            if let payload = _payload {
                _contentHostingView?.mainView.payload = payload
            } else {
                _tearDownContentHostingView()
            }
        }
    }
    
    var stateFlags: Set<_StateFlag> {
        _stateFlags
    }
    
    override var fittingSize: NSSize {
        if let contentHostingView = _contentHostingView {
            return contentHostingView.fittingSize
        } else {
            return .zero
        }
    }
    
    var payload: Payload? {
        get {
            _payload
        } set {
            _payload = newValue
        }
    }
    
    private var _contentHostingView: _ContentHostingView? {
        didSet {
            if let oldValue, oldValue.superview != nil {
                oldValue.removeFromSuperview()
            }
            
            if let _contentHostingView {
                CATransaction._withDisabledActions {
                    addSubview(_contentHostingView)
                }
            }
        }
    }
    
    fileprivate var contentHostingView: _ContentHostingView {
        get {
            let result = _contentHostingView ?? _initializeContentHostingView()
            
            if !(result.superview === self) {
                CATransaction._withDisabledActions {
                    addSubview(result)
                }
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
        self.parent = parent
        
        super.init(frame: .zero)
        
        self.identifier = identifier
        
        _setUpFrameObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        if let _contentHostingView, _contentHostingView.frame.size._isInvalidForIntrinsicContentSize {
            if !frame.size._isInvalidForIntrinsicContentSize {
                _contentHostingView.frame.size.width = self.frame.size.width
                
                _contentHostingView._SwiftUIX_setNeedsLayout()
                
                DispatchQueue.main.async {
                    guard _contentHostingView.superview != nil else {
                        return
                    }
                    
                    assert(_contentHostingView.superview != nil)
                    
                    _contentHostingView._SwiftUIX_layoutIfNeeded()
                }
            }
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
                
        let _contentHostingView = contentHostingView
        
        if !(_stateFlags.contains(.isInitializingContentHostingView) || inLiveResize) {
            _contentHostingView._SwiftUIX_setNeedsLayout()
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
        
        if self.payload == nil || !(self.payload?.itemPath == payload.itemPath) {
            self.payload = payload
        }
        
        _initializeContentHostingView(tableView: tableView)
    }
    
    override func prepareForReuse() {
        guard self.payload != nil || _contentHostingView != nil else {
            return
        }
        
        self._stateFlags.remove(.wasJustPutIntoUse)
        self._stateFlags.insert(.preparedForReuse)
        
        _tearDownContentHostingView()
        
        self.indexPath = nil
        self.payload = nil
    }
    
    // MARK: - Internal
    
    private func _setUpFrameObserver() {
        postsFrameChangedNotifications = true
        
        _frameObserver = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: self,
            queue: .main,
            using: { [weak self] _ in
                self?._updateContentHostingView()
            }
        )
    }
    
    @discardableResult
    private func _initializeContentHostingView(
        tableView: NSTableView? = nil
    ) -> _ContentHostingView {
        guard let payload else {
            fatalError()
        }
        
        self._stateFlags.insert(.isInitializingContentHostingView)
        
        defer {
            self._stateFlags.remove(.isInitializingContentHostingView)
        }
        
        let result: _ContentHostingView
        
        if let _result = self._expensiveCache?.cellContentView as? _ContentHostingView {
            result = _result
        
            if result.frame.size != self.frame.size, !result.frame.size._isInvalidForIntrinsicContentSize {
                self.frame.size = result.frame.size
            }

            self._contentHostingView = result
        } else {
            result = _ContentHostingView(
                mainView: ContentHostingContainer(
                    coordinator: .init(parent: nil),
                    payload: payload
                )
            )
            
            if superview == nil, frame.size.width == 0 {
                if let tableView, !tableView.frame.width._isInvalidForIntrinsicContentSize {
                    self.frame.size.width = tableView.frame.width
                }
            }
            
            if !frame.size.width._isInvalidForIntrinsicContentSize {
                if result.frame.size.width != frame.size.width {
                    result.frame.size.width = frame.size.width
            
                    // self._SwiftUIX_setNeedsLayout()
                    // self._SwiftUIX_layoutIfNeeded()
                }
            }
            
            self._contentHostingView = result
            self._expensiveCache?.cellContentView = result
        }
        
        assert(result.superview != nil)
        
        return result
    }
    
    private func _updateContentHostingView() {
        guard !(self.frame.size == _lastFrameSize) else {
            return
        }
        
        /*defer {
            _lastFrameSize = self.frame.size
        }
        
        guard let _contentHostingView = _contentHostingView else {
            return
        }
        
        if let maxWidth = _maximumContentViewWidth {
            if _contentHostingView.mainView.maxContentViewWidth != maxWidth {
                _withoutAppKitOrUIKitAnimation {
                    if maxWidth.isNormal && maxWidth > 0 {
                        _contentHostingView.mainView.maxContentViewWidth = maxWidth
                    } else {
                        _contentHostingView.mainView.maxContentViewWidth = nil
                    }
                }
            }
        }*/
    }
    
    private func _tearDownContentHostingView() {
        guard _contentHostingView != nil else {
            if _stateFlags.contains(.preparedForReuse) {
                assert(payload == nil)
            }
            
            return
        }
        
        assert(payload != nil)
        
        guard let _contentHostingView = _contentHostingView else {
            return
        }
        
        CATransaction._withDisabledActions {
            _contentHostingView.removeFromSuperview()
        }
        
        self._contentHostingView = nil
    }
}

extension _PlatformTableCellView {
    fileprivate var _cheapCache: _CocoaListCache<Configuration>.CheapItemCache? {
        guard let payload else {
            return nil
        }
        
        return parent?.coordinator.cache[cheap: payload.itemPath]
    }
    
    fileprivate var _expensiveCache: _CocoaListCache<Configuration>.ExpensiveItemCache? {
        guard let payload else {
            return nil
        }
        
        return parent?.coordinator.cache[expensive: payload.itemPath]
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
    }
}

extension _PlatformTableCellView {
    fileprivate struct ContentHostingContainer: View {
        @ObservedObject var coordinator: ContentHostingViewCoordinator
        
        var payload: Payload
        
        @State private var didAppear: Bool = false
                
        var body: some View {
            payload.content
                .frame(width: didAppear ? nil : coordinator.parent?.frame.width)
                .frame(idealWidth: .greatestFiniteMagnitude, minHeight: 44)
                .id(payload.itemID)
                .onAppear {
                    if !didAppear {
                        didAppear = true
                    }
                }
                .transaction { transaction in
                    if !didAppear {
                        transaction.disablesAnimations = true
                    }
                }
        }
    }
    
    fileprivate final class ContentHostingViewCoordinator: ObservableObject {
        private enum StateFlag {
            case firstRenderComplete
        }
        
        private var stateFlags: Set<StateFlag> = []
        
        weak var parent: _ContentHostingView?
        
        init(parent: _ContentHostingView?) {
            self.parent = parent
        }
    }

    fileprivate final class _ContentHostingView: _CocoaHostingView<ContentHostingContainer> {
        private var _constraintsWithSuperview: [NSLayoutConstraint]? = []
        
        fileprivate lazy var contentHostingViewCoordinator = ContentHostingViewCoordinator(parent: self)

        fileprivate var parent: _PlatformTableCellView? {
            guard let result = superview as? _PlatformTableCellView else {
                return nil
            }
            
            guard !result.stateFlags.contains(.preparedForReuse) else {
                return nil
            }
            
            return result
        }
                
        override func _assembleCocoaHostingView() {
            self.mainView.coordinator = contentHostingViewCoordinator
            
            translatesAutoresizingMaskIntoConstraints = false
            
            if #available(macOS 13.0, *) {
                sizingOptions = .standardBounds
            }
            
            #if swift(>=5.9)
            if #available(macOS 14.0, *) {
                sceneBridgingOptions = []
            }
            #endif
        }
                
        var didJustMoveToSuperview: Bool = false
        
        override func viewWillMove(
            toSuperview newSuperview: NSView?
        ) {
            super.viewWillMove(toSuperview: newSuperview)
                        
            if newSuperview == nil {
                if let currentConstraints = self._constraintsWithSuperview {
                    NSLayoutConstraint.deactivate(currentConstraints)
                    
                    self._constraintsWithSuperview = nil
                }
            } else {
                if let lastContentSize = (newSuperview as? _PlatformTableCellView)?._cheapCache?.lastContentSize {
                    if frame.size != lastContentSize {
                        self.frame.size = lastContentSize
                    }
                }
            }
        }
        
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            
            if let superview {
                let constraints = [
                    self.topAnchor.constraint(equalTo: superview.topAnchor),
                    self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
                ]
                
                NSLayoutConstraint.activate(constraints)
                
                self._constraintsWithSuperview = constraints
                
                didJustMoveToSuperview = true
            } else {
                didJustMoveToSuperview = false
            }
            
            DispatchQueue.main.async {
                self.didJustMoveToSuperview = false
            }
        }
                
        override func setFrameSize(_ newSize: NSSize) {
            guard !newSize.width._isInvalidForIntrinsicContentSize else {
                return
            }

            /*if !self.frame.size.isAreaZero {
                if self.frame.size.width == newSize.width, self.frame.size.height.isApproximatelyEqual(to: newSize.height, withThreshold: 1) {
                    print("HOL UP")
                }
                print(self.frame.size, newSize)
            }*/

            super.setFrameSize(newSize)
        }
        
        override func resizeSubviews(
            withOldSize oldSize: NSSize
        ) {
            guard !self.frame.width._isInvalidForIntrinsicContentSize else {
                return
            }
            
            super.resizeSubviews(withOldSize: oldSize)
            
            guard let parent else {
                return
            }
            
            parent._cheapCache?.lastContentSize = frame.size
        }

        override func invalidateIntrinsicContentSize() {
            guard !didJustMoveToSuperview else {
                return
            }
            
            parent?._cheapCache?.lastContentSize = nil
            
            super.invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - Diagnostics

extension NSView {
    private struct AssociatedKeys {
        static var debugBackgroundView: Void = ()
    }
    
    var _SwiftUIX_debugBackgroundView: NSView {
        get {
            if let bgView = objc_getAssociatedObject(self, &AssociatedKeys.debugBackgroundView) as? NSView {
                return bgView
            }
            
            let newView = NSView(frame: self.bounds)
            
            newView.autoresizingMask = [.width, .height]
            newView.wantsLayer = true
            
            self.addSubview(newView, positioned: .below, relativeTo: self.subviews.first)
            
            objc_setAssociatedObject(self, &AssociatedKeys.debugBackgroundView, newView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return newView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.debugBackgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func _SwiftUIX_setDebugBackgroundColor(_ color: NSColor) {
        DispatchQueue.main.async {
            self._SwiftUIX_debugBackgroundView.layer?.backgroundColor = color.cgColor
        }
    }
}

#endif
