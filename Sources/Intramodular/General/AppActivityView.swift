//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct AppActivityView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIActivityViewController
    
    private let activityItems: [Any]
    private let applicationActivities: [UIActivity]?
    
    private var excludedActivityTypes: [UIActivity.ActivityType] = []
    
    public init(
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(activityItems: activityItems, applicationActivities: applicationActivities)
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
