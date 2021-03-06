//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingView<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = CocoaHostingController<Content>
    
    private let mainView: Content
    
    public init(mainView: Content) {
        self.mainView = mainView
    }
    
    public init(@ViewBuilder mainView: () -> Content) {
        self.mainView = mainView()
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(mainView: mainView)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.mainView = mainView
    }
}

#else

public struct CocoaHostingView<Content: View>: View {
    private let mainView: Content
    
    public init(mainView: Content) {
        self.mainView = mainView
    }
    
    public init(@ViewBuilder mainView: () -> Content) {
        self.mainView = mainView()
    }
    
    public var body: some View {
        mainView
    }
}

#endif
