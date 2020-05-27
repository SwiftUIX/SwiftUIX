//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS)

/// A SwiftUI port of `UIActivityView`.
public struct ShareSheet {
    public typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    private let activityItems: [Any]
    
    private let applicationActivities: [UIActivity]?
    private let excludedActivityTypes: [UIActivity.ActivityType]?
    
    private let callback: Callback?
    
    public init(_ activityItems: [Any], applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil, callback: Callback? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.callback = callback
    }
}

extension ShareSheet : UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}

extension View {
    
    /// Presents a share sheet
    public func shareSheet(isPresented: Binding<Bool>, _ activityItems: [Any], applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil, callback: ShareSheet.Callback? = nil) -> some View {
        
        self.sheet(isPresented: isPresented) {
            ShareSheet(activityItems, applicationActivities: applicationActivities, excludedActivityTypes: excludedActivityTypes, callback: callback)
        }
        
    }
    
}

#endif
