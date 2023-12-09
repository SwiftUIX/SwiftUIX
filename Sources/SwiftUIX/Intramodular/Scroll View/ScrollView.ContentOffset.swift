//
// Copyright (c) Vatsal Manot
//

import SwiftUI
import Swift

public struct ScrollViewContentOffset: Hashable {
    public enum Origin {
        case topLeading
        case bottomTrailing
    }
    
    var containerBounds: CGRect
    var contentSize: CGSize
    var contentInsets: EdgeInsets
    var contentOffset: CGPoint
    
    public init(
        containerBounds: CGRect,
        contentSize: CGSize,
        contentInsets: EdgeInsets,
        contentOffset: CGPoint
    ) {
        self.containerBounds = containerBounds
        self.contentSize = contentSize
        self.contentInsets = contentInsets
        self.contentOffset = contentOffset
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(containerBounds.origin.x)
        hasher.combine(containerBounds.origin.y)
        hasher.combine(containerBounds.width)
        hasher.combine(containerBounds.height)
        hasher.combine(contentSize.width)
        hasher.combine(contentSize.height)
        hasher.combine(contentInsets.top)
        hasher.combine(contentInsets.leading)
        hasher.combine(contentInsets.bottom)
        hasher.combine(contentInsets.trailing)
        hasher.combine(contentOffset.x)
        hasher.combine(contentOffset.y)
    }
}

extension ScrollView {
    public typealias ContentOffset = ScrollViewContentOffset
}

extension ScrollView.ContentOffset {
    public var absoluteContentAlignment: Alignment? {
        switch contentOffset {
            case contentOffset(for: .center):
                return .center
            case contentOffset(for: .leading):
                return .leading
            case contentOffset(for: .trailing):
                return .trailing
            case contentOffset(for: .top):
                return .top
            case contentOffset(for: .bottom):
                return .bottom
            case contentOffset(for: .topLeading):
                return .topLeading
            case contentOffset(for: .topTrailing):
                return .topTrailing
            case contentOffset(for: .bottomLeading):
                return .topTrailing
            case contentOffset(for: .bottomTrailing):
                return .topTrailing
                
            default:
                return nil
        }
    }
    
    public func value(from origin: Origin) -> CGPoint {
        switch origin {
            case .topLeading:
                return contentOffset
            case .bottomTrailing: do {
                return .init(
                    x: contentOffset.x - (contentSize.width - containerBounds.width),
                    y: contentOffset.y - (contentSize.height - containerBounds.height)
                )
            }
        }
    }
    
    public func fractionalValue(from origin: Origin) -> CGPoint {
        return .init(
            x: value(from: origin).x == 0
                ? 0
                : value(from: origin).x / (contentSize.width - containerBounds.width),
            y: value(from: origin).y == 0
                ? 0
                : value(from: origin).y / (contentSize.height - containerBounds.height)
        )
    }
    
    mutating func setContentAlignment(_ alignment: Alignment) {
        self.contentOffset = contentOffset(for: alignment)
    }
}

extension ScrollView.ContentOffset {
    private func contentOffset(for alignment: Alignment) -> CGPoint {
        var offset: CGPoint = .zero
        
        switch alignment.horizontal {
            case .leading:
                offset.x = 0
            case .center:
                offset.x = (contentSize.width - containerBounds.size.width) / 2
            case .trailing:
                offset.x = contentSize.width - containerBounds.size.width
            default:
                assertionFailure()
        }
        
        switch alignment.vertical {
            case .top:
                offset.y = 0
            case .center:
                offset.y = (contentSize.height - containerBounds.size.height) / 2
            case .bottom:
                offset.y = max(-contentInsets.top, contentSize.height - (containerBounds.size.height - contentInsets.bottom))
            default:
                assertionFailure()
        }
        
        return offset
    }
}

// MARK: - Helpers

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension UIScrollView {
    var currentVerticalAlignment: VerticalAlignment? {
        let currentOffset = contentOffset.y
        
        if contentSize.height > frame.height {
            let topContentOffset = -contentInset.top
            let bottomContentOffset = contentSize.height - (frame.height - adjustedContentInset.bottom)
            
            if abs(bottomContentOffset - currentOffset) < 5 {
                return .bottom
            } else if abs(topContentOffset - currentOffset) < 5 {
                return .top
            }
        } else {
            return .center
        }
        
        return nil
    }
    
    func contentOffset<Content: View>(
        forContentType type: Content.Type
    ) -> ScrollView<Content>.ContentOffset {
        .init(
            containerBounds: bounds,
            contentSize: contentSize,
            contentInsets: .init(contentInset),
            contentOffset: contentOffset
        )
    }
    
    func setContentOffset(
        _ offset: ScrollViewContentOffset,
        animated: Bool
    ) {
        setContentOffset(offset.contentOffset, animated: animated)
    }
    
    func setContentAlignment(
        _ alignment: Alignment?,
        animated: Bool
    ) {
        guard let alignment = alignment else {
            return
        }
        
        var offset = contentOffset(forContentType: AnyView.self)
        
        offset.setContentAlignment(alignment)
        
        setContentOffset(offset, animated: animated)
    }
}

#endif
