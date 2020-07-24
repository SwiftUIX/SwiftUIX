//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import LinkPresentation
import Swift
import SwiftUI

/// A rich visual representation of a link.
public struct LinkPresentationView: View {
    @usableFromInline
    @Environment(\.errorContext) var errorContext
    
    public let url: URL?
    public let metadata: LPLinkMetadata?
    
    #if !os(tvOS)
    @usableFromInline
    @State var metadataProvider: LPMetadataProvider?
    #endif
    @usableFromInline
    @State var isFetchingMetadata: Bool = false
    @usableFromInline
    @State var fetchedMetadata: LPLinkMetadata?
    
    @usableFromInline
    var disableFetchingMetadata: Bool = false
    @usableFromInline
    var isCompact: Bool = false
    
    @inlinable
    public init(url: URL) {
        self.url = url
        self.metadata = nil
    }
    
    @inlinable
    public init(metadata: LPLinkMetadata) {
        self.url = nil
        self.metadata = metadata
    }
    
    @inlinable
    public var body: some View {
        _LinkPresentationView(
            url: url,
            metadata: (fetchedMetadata ?? metadata),
            isCompact: isCompact
        )
        .equatable()
        .onAppear(perform: fetchMetadata)
        .id(url ?? metadata?.originalURL)
    }
    
    @usableFromInline
    func fetchMetadata() {
        #if !os(tvOS)
        guard !disableFetchingMetadata else {
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
                
                if let error = error {
                    self.errorContext.push(error)
                }
            }
        }
        #endif
    }
}

// MARK: - API -

extension LinkPresentationView {
    public func disableFetchingMetadata(_ disableFetchingMetadata: Bool) -> Self {
        then({ $0.disableFetchingMetadata = disableFetchingMetadata })
    }
    
    public func compact(_ isCompact: Bool) -> Self {
        then({ $0.isCompact = isCompact })
    }
}

// MARK: - Implementation -

@usableFromInline
struct _LinkPresentationView: AppKitOrUIKitViewRepresentable, Equatable {
    public typealias AppKitOrUIKitViewType = LPLinkView
    
    @usableFromInline
    var url: URL?
    @usableFromInline
    var metadata: LPLinkMetadata?
    @usableFromInline
    var isCompact: Bool
    
    @usableFromInline
    init(url: URL?, metadata: LPLinkMetadata?, isCompact: Bool) {
        self.url = url
        self.metadata = metadata
        self.isCompact = isCompact
    }
    
    @usableFromInline
    func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        if let metadata = metadata {
            return LPLinkView(metadata: metadata)
        } else if let url = url {
            return LPLinkView(url: url)
        } else {
            assertionFailure()
            
            return LPLinkView(metadata: LPLinkMetadata())
        }
    }
    
    @usableFromInline
    func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        if let metadata = metadata {
            view.metadata = metadata
        }
        
        if isCompact {
            if !view.isHorizontalContentHuggingPriorityHigh && !view.isVerticalContentHuggingPriorityHigh {
                view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                view.setContentHuggingPriority(.defaultHigh, for: .vertical)
            }
        } else {
            if view.isHorizontalContentHuggingPriorityHigh && view.isVerticalContentHuggingPriorityHigh {
                view.setContentHuggingPriority(.defaultLow, for: .horizontal)
                view.setContentHuggingPriority(.defaultLow, for: .vertical)
            }
        }
    }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.isCompact == rhs.isCompact else {
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
