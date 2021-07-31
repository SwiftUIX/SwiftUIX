//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import LinkPresentation
import Swift
import SwiftUI

/// A rich visual representation of a link.
public struct LinkPresentationView<Placeholder: View>: Identifiable, View {
    @usableFromInline
    let url: URL?
    @usableFromInline
    let metadata: LPLinkMetadata?
    @usableFromInline
    let onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)?
    @usableFromInline
    let placeholder: Placeholder
    
    @usableFromInline
    var disableMetadataFetch: Bool = false
    
    public var id: some Hashable {
        url ?? metadata?.originalURL
    }
    
    public var body: some View {
        _LinkPresentationView(
            url: url,
            metadata: metadata,
            onMetadataFetchCompletion: onMetadataFetchCompletion,
            placeholder: placeholder,
            disableMetadataFetch: disableMetadataFetch
        )
        .id(id)
        .clipped()
    }
}

// MARK: - API -

extension LinkPresentationView {
    @inlinable
    public init(
        url: URL,
        onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)? = nil,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.metadata = nil
        self.onMetadataFetchCompletion = onMetadataFetchCompletion
        self.placeholder = placeholder()
    }
    
    @inlinable
    public init(
        url: URL,
        metadata: LPLinkMetadata?,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.metadata = metadata
        self.onMetadataFetchCompletion = nil
        self.placeholder = placeholder()
    }
    
    @inlinable
    public init(metadata: LPLinkMetadata, @ViewBuilder placeholder: () -> Placeholder) {
        self.url = nil
        self.metadata = metadata
        self.onMetadataFetchCompletion = nil
        self.placeholder = placeholder()
    }
}

extension LinkPresentationView where Placeholder == EmptyView {
    @inlinable
    public init(
        url: URL,
        onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)? = nil
    ) {
        self.init(url: url, onMetadataFetchCompletion: onMetadataFetchCompletion) {
            EmptyView()
        }
    }
    
    @inlinable
    public init(
        url: URL,
        metadata: LPLinkMetadata?
    ) {
        self.init(url: url, metadata: metadata, placeholder: { EmptyView() })
    }
    
    @inlinable
    public init(metadata: LPLinkMetadata) {
        self.init(metadata: metadata) {
            EmptyView()
        }
    }
}

extension LinkPresentationView {
    public func disableMetadataFetch(_ disableMetadataFetch: Bool) -> Self {
        then({ $0.disableMetadataFetch = disableMetadataFetch })
    }
}

// MARK: - Implementation -

@usableFromInline
struct _LinkPresentationView<Placeholder: View>: Identifiable, View {
    @usableFromInline
    @Environment(\.errorContext) var errorContext
    @usableFromInline
    @_UniqueStateCache(for: Self.self) var cache
    
    let url: URL?
    @usableFromInline
    let metadata: LPLinkMetadata?
    @usableFromInline
    let onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)?
    @usableFromInline
    let placeholder: Placeholder
    
    @usableFromInline
    var disableMetadataFetch: Bool
    
    #if !os(tvOS)
    @usableFromInline
    @State var metadataProvider: LPMetadataProvider?
    #endif
    @usableFromInline
    @State var isFetchingMetadata: Bool = false
    @usableFromInline
    @State var fetchedMetadata: LPLinkMetadata?
    
    @usableFromInline
    var id: some Hashable {
        url ?? metadata?.originalURL
    }
    
    private var isPlaceholderVisible: Bool {
        placeholder is EmptyView ? false : (metadata ?? fetchedMetadata) == nil
    }
    
    @usableFromInline
    var body: some View {
        ZStack {
            _LPLinkViewRepresentable<Placeholder>(
                url: url,
                metadata: (fetchedMetadata ?? metadata)
            )
            .equatable()
            .visible(!isPlaceholderVisible)
            
            placeholder
                .accessibility(hidden: placeholder is EmptyView)
                .visible(isPlaceholderVisible)
        }
        .onAppear(perform: fetchMetadata)
        .onChange(of: id) { _ in
            self.fetchedMetadata = nil
            
            fetchMetadata()
        }
    }
    
    #if !os(tvOS)
    @usableFromInline
    func fetchMetadata() {
        guard !disableMetadataFetch else {
            return
        }
        
        do {
            if let url = url, let metadata = try cache.decache(LPLinkMetadata.self, forKey: url) {
                self.fetchedMetadata = metadata
            }
        } catch {
            errorContext.push(error)
        }
        
        guard fetchedMetadata == nil else {
            return
        }
        
        guard let url = url ?? metadata?.originalURL else {
            return
        }
        
        guard !isFetchingMetadata else {
            return
        }
        
        metadataProvider = LPMetadataProvider()
        isFetchingMetadata = true
        
        metadataProvider?.startFetchingMetadata(for: url) { metadata, error in
            DispatchQueue.asyncOnMainIfNecessary {
                self.fetchedMetadata = metadata
                self.isFetchingMetadata = false
                
                if let metadata = metadata {
                    self.onMetadataFetchCompletion?(.success(metadata))
                } else if let error = error {
                    if let onMetadataFetchCompletion = self.onMetadataFetchCompletion {
                        onMetadataFetchCompletion(.failure(error))
                    } else {
                        self.errorContext.push(error)
                    }
                }
                
                if let metadata = metadata {
                    self.errorContext.withCriticalScope {
                        try self.cache.cache(metadata, forKey: url)
                    }
                }
            }
        }
    }
    #else
    @usableFromInline
    func fetchMetadata() {
        
    }
    #endif
}

@usableFromInline
struct _LPLinkViewRepresentable<Placeholder: View>: AppKitOrUIKitViewRepresentable, Equatable {
    public typealias AppKitOrUIKitViewType = LPLinkView
    
    @usableFromInline
    var url: URL?
    @usableFromInline
    var metadata: LPLinkMetadata?
    
    @usableFromInline
    init(
        url: URL?,
        metadata: LPLinkMetadata?
    ) {
        self.url = url
        self.metadata = metadata
    }
    
    @usableFromInline
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let linkView: LPLinkView
        if let metadata = metadata {
            linkView = LPLinkView(metadata: metadata)
        } else if let url = url {
            linkView = LPLinkView(url: url)
        } else {
            assertionFailure()
            linkView = LPLinkView(metadata: LPLinkMetadata())
        }
        
        linkView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        linkView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return linkView
    }
    
    @usableFromInline
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        if let metadata = metadata {
            view.metadata = metadata
        }
    }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
        if let lhsUrl = lhs.url, let rhsUrl = rhs.url {
            guard lhsUrl == rhsUrl else {
                return false
            }
        }
        
        if lhs.metadata == nil && rhs.metadata == nil {
            return lhs.url == rhs.url
        } else if lhs.metadata == nil || rhs.metadata == nil {
            return false
        } else if let lhsMetadata = lhs.metadata, let rhsMetadata = rhs.metadata {
            return lhsMetadata._isEqual(to: rhsMetadata)
        } else {
            return lhs.url == rhs.url && lhs.metadata == rhs.metadata
        }
    }
}

fileprivate extension LPLinkMetadata {
    func _isEqual(to other: LPLinkMetadata) -> Bool {
        true
            && originalURL == other.originalURL
            && url == other.url
            && title == other.title
            && iconProvider == other.iconProvider
            && imageProvider == other.imageProvider
            && videoProvider == other.videoProvider
            && remoteVideoURL == other.remoteVideoURL
    }
}

#endif
