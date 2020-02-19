//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHosted<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = CocoaHostingController<Content>
    
    private let rootView: Content
    
    public init(rootView: Content) {
        self.rootView = rootView
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(rootView: rootView)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootViewContent = rootView
    }
}

#else

public struct CocoaHosted<Content: View>: View {
    private let rootView: Content
    
    public init(rootView: Content) {
        self.rootView = rootView
    }
    
    public var body: some View {
        rootView
    }
}

#endif
