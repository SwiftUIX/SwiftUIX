//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SafariServices
import SwiftUI

public struct SafariView: View {
    private var configuration: Configuration
    
    public init(url: URL) {
        self.configuration = .init(url: url)
    }
    
    public var body: some View {
        Core(configuration: configuration)
    }
}

// MARK: - API -

extension SafariView {
    public func onFinish(perform action: @escaping () -> Void) -> Self {
        then({ $0.configuration.onFinish = action })
    }
    
    public func onCompletingInitialLoad(perform action: @escaping (Bool) -> Void) -> Self {
        then({ $0.configuration.onCompletingInitialLoad = action })
    }
    
    public func onInitialLoadRedirect(perform action: @escaping (URL) -> Void) -> Self {
        then({ $0.configuration.onInitialLoadRedirect = action })
    }
}

// MARK: - Auxiliary Implementation -

extension SafariView {
    private struct Configuration {
        var url: URL
        
        var onFinish: () -> Void = { }
        var onCompletingInitialLoad: (Bool) -> Void = { _ in }
        var onInitialLoadRedirect: (URL) -> Void = { _ in }
    }
    
    private struct Core: UIViewControllerRepresentable {
        typealias UIViewControllerType = SFSafariViewController
        
        final class Coordinator: NSObject, SFSafariViewControllerDelegate {
            var configuration: SafariView.Configuration
            
            init(configuration: SafariView.Configuration) {
                self.configuration = configuration
            }
            
            func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
                return []
            }
            
            func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
                return []
            }
            
            func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                configuration.onFinish()
            }
            
            func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
                configuration.onCompletingInitialLoad(didLoadSuccessfully)
            }
            
            func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
                configuration.onInitialLoadRedirect(URL)
            }
        }
        
        let configuration: Configuration
        
        func makeUIViewController(context: Context) -> UIViewControllerType {
            .init(url: configuration.url)
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            context.coordinator.configuration = configuration
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(configuration: configuration)
        }
    }
}

#endif
