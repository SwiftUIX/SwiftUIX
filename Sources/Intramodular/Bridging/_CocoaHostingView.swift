//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

open class _CocoaHostingView<Content: View>: AppKitOrUIKitHostingView<CocoaHostingControllerContent<Content>>, _CocoaHostingControllerOrView {
    public typealias RootView = CocoaHostingControllerContent<Content>
    
    public var _configuration: CocoaHostingControllerConfiguration = .init() {
        didSet {
            rootView.parentConfiguration = _configuration
        }
    }
    
    public var _observedPreferenceValues = _ObservedPreferenceValues()
    
    public var mainView: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public init(mainView: Content) {
        super.init(
            rootView: .init(
                parent: nil,
                parentConfiguration: _configuration,
                content: mainView
            )
        )
        
        rootView.parent = self
    }
    
    public required init(rootView: RootView) {
        super.init(rootView: rootView)
    }
    
    public required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    #endif
}

// MARK: - WIP

#if os(macOS)
extension _CocoaHostingView {
    private func setUpSizeObserver() {
        NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let view = notification.object as? NSView, view.className == "SwiftUI._NSGraphicsView" else {
                return
            }
            
            guard view.superview == self else {
                return
            }
            
            DispatchQueue.main.async { [weak view] in
                guard let view = view else {
                    return
                }
                
                guard !view.frame.size.isAreaZero else {
                    return
                }
                
                self.setFrameSize(view.frame.size)
            }
        }
    }
}
#endif

#endif
