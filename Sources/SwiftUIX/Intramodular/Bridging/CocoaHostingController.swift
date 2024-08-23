//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public struct CocoaHostingControllerConfiguration {
    var _isMeasuringSize: Bool = false
    
    lazy var _measuredSizePublisher = {
        self._isMeasuringSize = true
        
        return PassthroughSubject<CGSize, Never>()
    }()
    
    var observedPreferenceKeys: [any PreferenceKey.Type] = []
    var preferenceValueObservers: [AnyViewModifier] = []
}

@_documentation(visibility: internal)
open class CocoaHostingController<Content: View>: AppKitOrUIKitHostingController<CocoaHostingControllerContent<Content>>, _CocoaHostingControllerOrView, CocoaViewController {
    public var _configuration: CocoaHostingControllerConfiguration = .init() {
        didSet {
            rootView.parentConfiguration = _configuration
        }
    }
    
    public var _hostingViewConfigurationFlags: Set<_CocoaHostingViewConfigurationFlag> = []
    public var _hostingViewStateFlags: Set<_CocoaHostingViewStateFlag> = []
            
    public var _SwiftUIX_cancellables: [AnyCancellable] = []
    
    public var _observedPreferenceValues = _ObservedPreferenceValues()
    public var _canBecomeFirstResponder: Bool? = nil
        
    var _safeAreaInsetsAreFixed: Bool = false
    var _namedViewDescriptions: [AnyHashable: _NamedViewDescription] = [:]
    var _presentationCoordinator: CocoaPresentationCoordinator
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var _transitioningDelegate: UIViewControllerTransitioningDelegate? {
        didSet {
            transitioningDelegate = _transitioningDelegate
        }
    }
    #endif
    var _isResizingParentWindow: Bool = false
    var _didResizeParentWindowOnce: Bool = false

    #if os(macOS)
    weak var _SwiftUIX_parentNSPopover: NSPopover? {
        didSet {
            if _SwiftUIX_parentNSPopover != nil {
                if #available(macOS 13.0, *) {
                    _assignIfNotEqual([.preferredContentSize], to: \.sizingOptions)
                }
            }
        }
    }
    #endif
    
    public var mainView: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    #if os(iOS)
    open override var canBecomeFirstResponder: Bool {
        _canBecomeFirstResponder ?? super.canBecomeFirstResponder
    }
    #endif

    public var shouldResizeToFitContent: Bool = false
    
    override public var presentationCoordinator: CocoaPresentationCoordinator {
        _presentationCoordinator
    }
    
    public init(
        mainView: Content,
        presentationCoordinator: CocoaPresentationCoordinator = .init()
    ) {
        self._presentationCoordinator = presentationCoordinator
        
        super.init(
            rootView: .init(
                parent: nil,
                parentConfiguration: _configuration,
                content: mainView
            )
        )
        
        presentationCoordinator.setViewController(self)
        
        self.rootView.parent = self
        
        if let mainView = mainView as? AnyPresentationView {
            #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
            #if os(iOS) || targetEnvironment(macCatalyst)
            hidesBottomBarWhenPushed = mainView.hidesBottomBarWhenPushed
            #endif
            modalPresentationStyle = .init(mainView.modalPresentationStyle)
            presentationController?.delegate = presentationCoordinator
            _transitioningDelegate = mainView.modalPresentationStyle.toTransitioningDelegate()
            #elseif os(macOS)
            fatalError("unimplemented")
            #endif
        }
    }
    
    @available(*, unavailable, renamed: "CocoaHostingController.init(mainView:)")
    public convenience init(rootView: Content) {
        self.init(mainView: rootView, presentationCoordinator: .init())
    }
    
    @_disfavoredOverload
    public convenience init(mainView: Content) {
        self.init(mainView: mainView, presentationCoordinator: .init())
    }
    
    public convenience init(@ViewBuilder mainView: () -> Content) {
        self.init(mainView: mainView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func withCriticalScope<Result>(
        _ flags: Set<_CocoaHostingViewConfigurationFlag>,
        perform action: () -> Result
    ) -> Result {
        assertionFailure("unimplemented")
    
        return action()
    }
    
    public func _configureSizingOptions(for type: AppKitOrUIKitResponder.Type) {
        #if os(macOS)
        switch type {
            case is AppKitOrUIKitWindow.Type:
                if #available(macOS 13.0, *) {
                    sizingOptions = [.intrinsicContentSize, .preferredContentSize]
                }
            default:
                assertionFailure()
        }
        #endif
    }

    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open func loadView() {
        super.loadView()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    #elseif os(macOS)
    override open func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override open func viewDidAppear() {
        super.viewDidAppear()
        
        #if os(macOS)
        if self.parent == nil {
            DispatchQueue.main.async {
                self._hostingViewStateFlags.insert(.hasAppearedAndIsCurrentlyVisible)
            }
        } else {
            _hostingViewStateFlags.insert(.hasAppearedAndIsCurrentlyVisible)
        }
        #else
        _hostingViewStateFlags.insert(.hasAppearedAndIsCurrentlyVisible)
        #endif
    }
    
    override open func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
    override open func viewDidDisappear() {
        super.viewDidDisappear()
        
        _hostingViewStateFlags.remove(.hasAppearedAndIsCurrentlyVisible)
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
        
        DispatchQueue.main.async {
            self.resizeParentWindowIfNecessary()
        }
    }
    
    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if shouldResizeToFitContent {
            view.invalidateIntrinsicContentSize()
        }
    }
    
    #elseif os(macOS)
    override open func viewDidLayout() {
        super.viewDidLayout()
        
        if #available(macOS 13.0, *) {
            let isManagedBySwiftUI = sizingOptions.contains(.preferredContentSize) || sizingOptions.contains(.intrinsicContentSize)
            
            if !isManagedBySwiftUI {
                _determineAndSetPreferredContentSize()
            }
        } else {
            _determineAndSetPreferredContentSize()
        }
    }
    #endif
    
    private func _determineAndSetPreferredContentSize() {
        guard !view.frame.size._isNormal || view.frame.size.isAreaZero else {
            return
        }
        
        let size = sizeThatFits(in: AppKitOrUIKitView.layoutFittingCompressedSize)

        #if os(macOS)
        if !size.isAreaZero {
            DispatchQueue.main.async { [weak self] in
                if let popover = self?._SwiftUIX_parentNSPopover {
                    popover._assignIfNotEqual(size, to: \.contentSize)
                } else {
                    self?._assignIfNotEqual(size, to: \.preferredContentSize)
                }
            }
        }
        #endif
    }
    
    public func _namedViewDescription(
        for name: AnyHashable
    ) -> _NamedViewDescription? {
        _namedViewDescriptions[name]
    }
    
    public func _setNamedViewDescription(
        _ description: _NamedViewDescription?,
        for name: AnyHashable
    ) {
        _namedViewDescriptions[name] = description
    }
    
    public func _SwiftUIX_sizeThatFits(in size: CGSize) -> CGSize {
        sizeThatFits(in: size)
    }
    
    private func resizeParentWindowIfNecessary() {
        guard !_didResizeParentWindowOnce else {
            return
        }
        
        guard !_isResizingParentWindow else {
            return
        }
        
        _isResizingParentWindow = true
        
        defer {
            _isResizingParentWindow = false
        }
        
        #if os(iOS) && canImport(CoreTelephony)
        if let window = view.window, window.canResizeToFitContent, view.frame.size.isAreaZero || view.frame.size == Screen.size {
            window.frame.size = self.sizeThatFits(AppKitOrUIKitLayoutSizeProposal(targetSize: Screen.main.bounds.size))
            
            _didResizeParentWindowOnce = true
        }
        #endif
    }
}

extension CocoaHostingController {
    /// https://twitter.com/b3ll/status/1193747288302075906
    public func _disableSafeAreaInsetsIfNecessary() {
        defer {
            _safeAreaInsetsAreFixed = true
        }
        
        guard !_safeAreaInsetsAreFixed else {
            return
        }
        
        _disableSafeAreaInsets()
    }
}

extension AppKitOrUIKitHostingController {
    /// https://twitter.com/b3ll/status/1193747288302075906
    public func _disableSafeAreaInsets() {
        #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
        guard let viewClass = object_getClass(view), !String(cString: class_getName(viewClass)).hasSuffix("_SwiftUIX_patched") else {
            return
        }

        let className = String(cString: class_getName(viewClass)).appending("_SwiftUIX_patched")
        
        if let viewSubclass = NSClassFromString(className) {
            object_setClass(view, viewSubclass)
        } else {
            className.withCString { className in
                guard let subclass = objc_allocateClassPair(viewClass, className, 0) else {
                    return
                }
                
                if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                    let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                        return .zero
                    }
                    
                    class_addMethod(subclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
                }
                
                if let method2 = class_getInstanceMethod(viewClass, #selector(getter: UIView.safeAreaLayoutGuide))  {
                    let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = { (_: AnyObject!) -> UILayoutGuide? in
                        return nil
                    }
                    
                    class_replaceMethod(viewClass, #selector(getter: UIView.safeAreaLayoutGuide), imp_implementationWithBlock(safeAreaLayoutGuide), method_getTypeEncoding(method2))
                }
                
                objc_registerClassPair(subclass)
                object_setClass(view, subclass)
            }

            view.setNeedsDisplay()
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        #endif
    }
}

#endif
