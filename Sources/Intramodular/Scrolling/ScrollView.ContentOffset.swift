//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension ScrollView {
    public struct ContentOffset {
        public enum Origin {
            case topLeading
            case bottomTrailing
        }
        
        fileprivate var containerBounds: CGRect
        fileprivate var contentSize: CGSize
        fileprivate var contentOffset: CGPoint
    }
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
    
    public func relativeValue(from origin: Origin) -> CGPoint {
        return .init(
            x: value(from: origin).x / (contentSize.width - containerBounds.width),
            y: value(from: origin).y / (contentSize.height - containerBounds.height)
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
                fatalError()
        }
        
        switch alignment.vertical {
            case .top:
                offset.y = 0
            case .center:
                offset.y = (contentSize.height - containerBounds.size.height) / 2
            case .bottom:
                offset.y = contentSize.height - containerBounds.size.height
            default:
                fatalError()
        }
        
        return offset
    }
}

// MARK: - Helpers -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIScrollView {
    func contentOffset<Content: View>(
        forContentType type: Content.Type
    ) -> ScrollView<Content>.ContentOffset {
        .init(containerBounds: bounds, contentSize: contentSize, contentOffset: contentOffset)
    }
    
    func setContentOffset<Content: View>(_ offset: ScrollView<Content>.ContentOffset, animated: Bool) {
        setContentOffset(offset.contentOffset, animated: animated)
    }
    
    func setContentAlignment(_ alignment: Alignment?, animated: Bool) {
        guard let alignment = alignment else {
            return
        }
        
        var offset = contentOffset(forContentType: AnyView.self)
        
        offset.setContentAlignment(alignment)
        
        setContentOffset(offset, animated: animated)
    }
}

#endif
