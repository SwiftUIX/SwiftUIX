//
// Copyright (c) Vatsal Manot
//

#if os(iOS)

import Combine
import Swift
import SwiftUI
import UniformTypeIdentifiers

public struct DocumentPicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIDocumentPickerViewController
    
    private let mode: UIDocumentPickerMode
    private let allowedContentTypes: [String]
    private let onCompletion: (Result<[URL], Error>) -> Void
    
    private var allowsMultipleSelection: Bool = false
    private var shouldShowFileExtensions: Bool = false
    private var directoryURL: URL?
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let uiViewController = UIDocumentPickerViewController(
            documentTypes: allowedContentTypes,
            in: mode
        )
        
        uiViewController.delegate = context.coordinator
        
        return uiViewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.allowsMultipleSelection = allowsMultipleSelection
        uiViewController.shouldShowFileExtensions = shouldShowFileExtensions
        uiViewController.directoryURL = directoryURL
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let base: DocumentPicker
        
        init(parent: DocumentPicker) {
            self.base = parent
            super.init()
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            urls.forEach({ _ = $0.startAccessingSecurityScopedResource() })
            
            defer {
                urls.forEach({ $0.stopAccessingSecurityScopedResource() })
            }
            
            base.onCompletion(.success(urls))
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

// MARK: - API

extension DocumentPicker {
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(
        mode: UIDocumentPickerMode,
        allowedContentTypes: [UTType],
        onCompletion: @escaping (Result<[URL], Error>) -> Void
    ) {
        self.mode = mode
        self.allowedContentTypes = allowedContentTypes.map { $0.identifier }
        self.onCompletion = onCompletion
    }
}

extension DocumentPicker {
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        then({ $0.allowsMultipleSelection = allowsMultipleSelection })
    }
    
    public func shouldShowFileExtensions(_ shouldShowFileExtensions: Bool) -> Self {
        then({ $0.shouldShowFileExtensions = shouldShowFileExtensions })
    }
    
    public func directoryURL(_ directoryURL: URL?) -> Self {
        then({ $0.directoryURL = directoryURL })
    }
}

#endif
