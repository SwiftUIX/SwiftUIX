//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SafariServices
import SwiftUI

/// A view that provides a visible standard interface for browsing the web.
///
/// This view has its own navigation bar and bottom toolbar.
public struct SafariView: View {
    fileprivate struct Configuration {
        var url: URL
        var onFinish: () -> Void = { }
        var onCompletingInitialLoad: (Bool) -> Void = { _ in }
        var onInitialLoadRedirect: (URL) -> Void = { _ in }
        
        var entersReaderIfAvailable: Bool = false
    }
    
    private var configuration: Configuration
    
    public init(url: URL) {
        self.configuration = .init(url: url)
    }
    
    public var body: some View {
        _Body(configuration: configuration)
            .navigationBarHidden(true)
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
    
    public func entersReaderIfAvailable(_ entersReaderIfAvailable: Bool) -> Self {
        then({ $0.configuration.entersReaderIfAvailable = entersReaderIfAvailable })
    }
}

// MARK: - Auxiliary Implementation -

extension SafariView {
    fileprivate struct _Body: UIViewControllerRepresentable {
        typealias UIViewControllerType = SFSafariViewController
        
        let configuration: Configuration
        
        func makeUIViewController(context: Context) -> UIViewControllerType {
            let viewControllerConfiguration = UIViewControllerType.Configuration()
            
            viewControllerConfiguration.entersReaderIfAvailable = true
            
            return .init(url: configuration.url, configuration: viewControllerConfiguration)
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            context.coordinator.configuration = configuration
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(configuration: configuration)
        }
    }
}

extension SafariView._Body {
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
}

#endif
