//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(macOS)

public final class _PlatformTableContentHostingViewCoordinator<ListConfiguration: _CocoaListConfigurationType>: ObservableObject {
    
}

class _PlatformTableCellView<Configuration: _CocoaListConfigurationType>: NSTableCellView {
    weak var parent: _PlatformTableViewContainer<Configuration>?

    private var _frameObserver: NSObjectProtocol?
    private var _lastFrameSize: CGSize? = nil
    private var _stateFlags: Set<_StateFlag> = []
        
    var indexPath: IndexPath?
    var _payload: Payload? {
        didSet {
            if let payload = _payload {
                _contentHostingView?.rootView.payload = payload
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
    
    let contentHostingViewCoordinator = _PlatformTableContentHostingViewCoordinator<Configuration>()

    private var _contentHostingView: _ContentHostingView? {
        didSet {
            if let oldValue, oldValue.superview != nil {
                oldValue.removeFromSuperview()
            }
            
            if let _contentHostingView {
                _withoutAppKitOrUIKitAnimation {
                    addSubview(_contentHostingView)
                }
            }
        }
    }
    
    fileprivate var contentHostingView: _ContentHostingView {
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
                _contentHostingView.rootView.maxContentViewWidth = _maximumContentViewWidth
                
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
        super.resizeSubviews(withOldSize: oldSize)
        
        guard oldSize != frame.size else {
            return
        }
        
        let _contentHostingView = contentHostingView
        
        if !_stateFlags.contains(.isInitializingContentHostingView) {
            _contentHostingView._SwiftUIX_setNeedsLayout()
            
            DispatchQueue.main.async {
                guard _contentHostingView.superview != nil else {
                    return
                }
                
                _contentHostingView._SwiftUIX_layoutIfNeeded()
            }
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        guard !stateFlags.contains(.wasJustPutIntoUse) else {
            return
        }
        
        super.invalidateIntrinsicContentSize()
    }
    
    func prepareForUse(
        payload: Payload
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
        
        _initializeContentHostingView()
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
    private func _initializeContentHostingView() -> _ContentHostingView {
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
            
            self._contentHostingView = result
            self._contentHostingView?.rootView.maxContentViewWidth = _maximumContentViewWidth
            
            if result.frame.size != self.frame.size, !result.frame.size._isInvalidForIntrinsicContentSize {
                self.frame.size = result.frame.size
            }
            
            self._SwiftUIX_setNeedsLayout()
            self._SwiftUIX_layoutIfNeeded()
        } else {
            result = _ContentHostingView(
                rootView: ContentHostingContainer(
                    coordinator: contentHostingViewCoordinator,
                    payload: payload,
                    maxContentViewWidth: _maximumContentViewWidth
                )
            )
            
            if !frame.size._isInvalidForIntrinsicContentSize {
                result.frame.size.width = frame.size.width
                
                self._SwiftUIX_setNeedsLayout()
                self._SwiftUIX_layoutIfNeeded()
            }
            
            self._contentHostingView = result
            self._contentHostingView?.rootView.maxContentViewWidth = _maximumContentViewWidth
            self._expensiveCache?.cellContentView = result
        }
        
        assert(result.superview != nil)
        
        return result
    }
    
    private func _updateContentHostingView() {
        guard !(self.frame.size == _lastFrameSize) else {
            return
        }
        
        defer {
            _lastFrameSize = self.frame.size
        }
        
        guard let _contentHostingView = _contentHostingView else {
            return
        }
        
        if let maxWidth = _maximumContentViewWidth {
            if _contentHostingView.rootView.maxContentViewWidth != maxWidth {
                _withoutAppKitOrUIKitAnimation {
                    if maxWidth.isNormal && maxWidth > 0 {
                        _contentHostingView.rootView.maxContentViewWidth = maxWidth
                    } else {
                        _contentHostingView.rootView.maxContentViewWidth = nil
                    }
                }
            }
        }
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
        
        _withoutAppKitOrUIKitAnimation {
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
    
    fileprivate struct ContentHostingContainer: View {
        @ObservedObject var coordinator: _PlatformTableContentHostingViewCoordinator<Configuration>
        
        var payload: Payload
        var maxContentViewWidth: CGFloat?
        
        @State private var didAppear: Bool = false
        
        var body: some View {
            payload.content
                .id(payload.itemID)
                .onAppear {
                    didAppear = true
                }
                .transaction { transaction in
                    if !didAppear {
                        transaction.disablesAnimations = true
                    }
                }
        }
    }
    
    fileprivate final class _ContentHostingView: NSHostingView<ContentHostingContainer> {
        private var _constraintsWithSuperview: [NSLayoutConstraint]? = []
        
        var parent: _PlatformTableCellView? {
            superview as? _PlatformTableCellView
        }
        
        required init(rootView: ContentHostingContainer) {
            super.init(rootView: rootView)
            
            translatesAutoresizingMaskIntoConstraints = false
            
            if #available(macOS 13.0, *) {
                sizingOptions = .standardBounds
            }
        }
        
        @MainActor
        required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func resizeSubviews(withOldSize oldSize: NSSize) {
            super.resizeSubviews(withOldSize: oldSize)
            
            guard let parent else {
                return
            }
            
            parent._cheapCache?.lastContentSize = frame.size
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
            }
        }
        
        override func viewWillMove(
            toSuperview newSuperview: NSView?
        ) {
            super.viewWillMove(toSuperview: newSuperview)
            
            if newSuperview == nil, let currentConstraints = self._constraintsWithSuperview {
                NSLayoutConstraint.deactivate(currentConstraints)
                
                self._constraintsWithSuperview = nil
            }
        }
    }
}

// MARK: - Diagnostics

extension NSTableCellView {
    private struct AssociatedKeys {
        static var backgroundView: Void = ()
    }
    
    var backgroundView: NSView {
        get {
            if let bgView = objc_getAssociatedObject(self, &AssociatedKeys.backgroundView) as? NSView {
                return bgView
            }
            
            let newView = NSView(frame: self.bounds)
            
            newView.autoresizingMask = [.width, .height]
            newView.wantsLayer = true
            
            self.addSubview(newView, positioned: .below, relativeTo: self.subviews.first)
            
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, newView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return newView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setBackgroundColor(_ color: NSColor) {
        DispatchQueue.main.async {
            self.backgroundView.layer?.backgroundColor = color.cgColor
        }
    }
}

#endif
