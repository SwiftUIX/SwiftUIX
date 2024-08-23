//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import LinkPresentation
import Swift
import SwiftUI

/// A rich visual representation of a link.
@_documentation(visibility: internal)
public struct LinkPresentationView<Placeholder: View>: Identifiable, View {
    let url: URL?
    let metadata: LPLinkMetadata?
    let onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)?
    let placeholder: Placeholder
    
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

// MARK: - API

extension LinkPresentationView {
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
    
    public init(metadata: LPLinkMetadata, @ViewBuilder placeholder: () -> Placeholder) {
        self.url = nil
        self.metadata = metadata
        self.onMetadataFetchCompletion = nil
        self.placeholder = placeholder()
    }
}

extension LinkPresentationView where Placeholder == EmptyView {
    public init(
        url: URL,
        onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)? = nil
    ) {
        self.init(url: url, onMetadataFetchCompletion: onMetadataFetchCompletion) {
            EmptyView()
        }
    }
    
    public init(
        url: URL,
        metadata: LPLinkMetadata?
    ) {
        self.init(url: url, metadata: metadata, placeholder: { EmptyView() })
    }
    
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

// MARK: - Implementation

struct _LinkPresentationView<Placeholder: View>: Identifiable, View {
    @Environment(\.handleLocalizedError) var handleLocalizedError
    @_UniqueKeyedViewCache(for: Self.self) var cache
    
    let url: URL?
    let metadata: LPLinkMetadata?
    let onMetadataFetchCompletion: ((Result<LPLinkMetadata, Error>) -> Void)?
    let placeholder: Placeholder
    
    var disableMetadataFetch: Bool
    
    #if !os(tvOS)
    @State var metadataProvider: LPMetadataProvider?
    #endif
    @State var isFetchingMetadata: Bool = false
    @State var fetchedMetadata: LPLinkMetadata?
    @State var proposedMinHeight: CGFloat?
    
    var id: some Hashable {
        url ?? metadata?.originalURL
    }
    
    private var isPlaceholderVisible: Bool {
        if placeholder is EmptyView {
            return false
        } else {
            return (metadata ?? fetchedMetadata) == nil
        }
    }
    
    var body: some View {
        ZStack {
            _LPLinkViewRepresentable<Placeholder>(
                url: url,
                metadata: (fetchedMetadata ?? metadata),
                proposedMinHeight: $proposedMinHeight
            )
            .equatable()
            .frame(minHeight: proposedMinHeight)
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
    func fetchMetadata() {
        guard !disableMetadataFetch else {
            return
        }
        
        do {
            if let url = url, let metadata = try cache.decache(LPLinkMetadata.self, forKey: url) {
                self.fetchedMetadata = metadata
                onMetadataFetchCompletion?(.success(metadata))
            }
        } catch {
            onMetadataFetchCompletion?(.failure(error))
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
                self.proposedMinHeight = nil
                
                if let metadata = metadata {
                    self.onMetadataFetchCompletion?(.success(metadata))
                } else if let error = error {
                    if let onMetadataFetchCompletion = self.onMetadataFetchCompletion {
                        onMetadataFetchCompletion(.failure(error))
                    }
                }
                
                if let metadata = metadata {
                    _ = try? self.cache.cache(metadata, forKey: url)
                }
            }
        }
    }
    #else
    func fetchMetadata() {
        
    }
    #endif
}

struct _LPLinkViewRepresentable<Placeholder: View>: AppKitOrUIKitViewRepresentable, Equatable {
    public typealias AppKitOrUIKitViewType = MutableAppKitOrUIKitViewWrapper<LPLinkView>
    
    var url: URL?
    var metadata: LPLinkMetadata?
    @Binding var proposedMinHeight: CGFloat?
    
    init(
        url: URL?,
        metadata: LPLinkMetadata?,
        proposedMinHeight: Binding<CGFloat?>
    ) {
        self.url = url
        self.metadata = metadata
        self._proposedMinHeight = proposedMinHeight
    }
    
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        DispatchQueue.main.async {
            self.proposedMinHeight = nil
        }
        
        if let metadata = metadata {
            return .init(base: LPLinkView(metadata: metadata))
        } else if let url = url {
            return .init(base: LPLinkView(url: url))
        } else {
            assertionFailure()
            
            return .init(base: LPLinkView(metadata: LPLinkMetadata()))
        }
    }
    
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        if let metadata = metadata {
            let wasMetadataPresent = view.base?.metadata.title != nil
            
            view.base?.metadata = metadata
            
            if !wasMetadataPresent {
                DispatchQueue.main.async {
                    self.proposeMinimumHeight(for: view)
                }
            }
        }
        
        self.proposeMinimumHeight(for: view)
    }
    
    private func proposeMinimumHeight(for view: AppKitOrUIKitViewType) {
        guard view.frame.minimumDimensionLength != 0 else {
            return
        }
        
        if view.frame.height == 0 && proposedMinHeight == nil {
            #if os(iOS) || targetEnvironment(macCatalyst)
            view.base!._UIKit_only_sizeToFit()
            #endif
            
            #if os(iOS) || targetEnvironment(macCatalyst)
            DispatchQueue.main.async {
                self.proposedMinHeight = view.base!.sizeThatFits(view.frame.size).height
            }
            #endif
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.proposedMinHeight == rhs.proposedMinHeight else {
            return false
        }
        
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
        var result = true
       
        result = result && originalURL == other.originalURL
        result = result && url == other.url
        result = result && title == other.title
        result = result && iconProvider == other.iconProvider
        result = result && imageProvider == other.imageProvider
        result = result && videoProvider == other.videoProvider
        result = result && remoteVideoURL == other.remoteVideoURL
        
        return result
    }
}

#endif
