//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct UIHostingViewControllerWrapper<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIHostingController<Content>
    
    private let rootView: Content
    
    public init(rootView: () -> Content) {
        self.rootView = rootView()
    }
    
    private var _onMake: (UIHostingController<Content>, Context) -> () = { _, _ in }
    private var _onUpdate: (UIHostingController<Content>, Context) -> () = { _,_ in }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType(rootView: rootView).then({ _onMake($0, context) })
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootView = rootView
        
        _onUpdate(uiViewController, context)
    }
    
    public func onMake(_ body: @escaping (UIHostingController<Content>, Context) -> ()) -> Self {
        then({ $0._onMake = body })
    }
    
    public func onUpdate(_ body: @escaping (UIHostingController<Content>, Context) -> ()) -> Self {
        then({ $0._onUpdate = body })
    }
}

#endif
