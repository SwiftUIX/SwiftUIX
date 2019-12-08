//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct ActivityServiceView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIActivityViewController
    
    private var activityItems: [Any]
    private var excludedActivityTypes: [UIActivity.ActivityType] = []
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(activityItems: activityItems, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.excludedActivityTypes = excludedActivityTypes
    }
    
    public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.completionWithItemsHandler = nil
    }
    
    public func excludeActivityTypes(_ activityTypes: [UIActivity.ActivityType]) -> Self {
        then({ $0.excludedActivityTypes = activityTypes })
    }
}

#endif
