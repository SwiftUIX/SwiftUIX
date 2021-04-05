//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A container for a view to be presented as a popover.
public struct Popover<Content: View> {
    public let content: Content
    
    public private(set) var attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds)
    public private(set) var permittedArrowDirections: PopoverArrowDirection = []
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension Popover {
    public func attachmentAnchor(_ anchor: PopoverAttachmentAnchor) -> Self {
        var result = self
        
        result.attachmentAnchor = anchor
        
        return result
    }
    
    public func permittedArrowDirections(_ directions: PopoverArrowDirection) -> Self {
        var result = self
        
        result.permittedArrowDirections = directions
        
        return result
    }
}

// MARK: - API -

extension PresentationLink {
    public init(
        destination: () -> Popover<Destination>,
        @ViewBuilder label: () -> Label
    ) {
        let destination = destination()
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        self.init(
            destination: destination.content,
            style: .popover(
                permittedArrowDirections: destination.permittedArrowDirections,
                attachmentAnchor: destination.attachmentAnchor
            ),
            label: label
        )
        #else
        self.init(destination: destination.content, label: label)
        #endif
    }
    
    public init(
        isPresented: Binding<Bool>,
        destination: () -> Popover<Destination>,
        @ViewBuilder label: () -> Label
    ) {
        let destination = destination()
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        self.init(
            destination: destination.content,
            isPresented: isPresented,
            style: .popover(
                permittedArrowDirections: destination.permittedArrowDirections,
                attachmentAnchor: destination.attachmentAnchor
            ),
            label: label
        )
        #else
        self.init(destination: destination.content, label: label)
        #endif
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        destination: () -> Popover<Destination>
    ) where Label == Text {
        self.init(destination: destination) {
            Text(title)
        }
    }
}

extension PresentationLink where Label == Image {
    public init(
        systemImage: SFSymbolName,
        destination: @escaping () -> Popover<Destination>
    ) {
        self.init(destination: destination) {
            Image(systemName: systemImage)
        }
    }
    
    public init(
        systemImage: SFSymbolName,
        isPresented: Binding<Bool>,
        destination: @escaping () -> Popover<Destination>
    ) {
        self.init(isPresented: isPresented, destination: destination) {
            Image(systemName: systemImage)
        }
    }
}

@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension PresentationLink where Label == SwiftUI.Label<Text, Image> {
    public init<S: StringProtocol>(
        _ title: S,
        systemImage: SFSymbolName,
        @ViewBuilder destination: @escaping () -> Popover<Destination>
    ) {
        self.init(destination: destination) {
            Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Auxiliary Implementation -

public struct PopoverArrowDirection: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let up = Self(rawValue: 1 << 0)
    public static let down = Self(rawValue: 1 << 1)
    public static let left = Self(rawValue: 1 << 2)
    public static let right = Self(rawValue: 1 << 3)
    
    public static let all: Self = [.up, .down, .left, .right]
}

#if os(iOS) || targetEnvironment(macCatalyst)
extension PopoverArrowDirection {
    public init(_ direction: UIPopoverArrowDirection) {
        self.init()
        
        if direction.contains(.up) {
            formUnion(.up)
        }
        
        if direction.contains(.down) {
            formUnion(.down)
        }
        
        if direction.contains(.left) {
            formUnion(.down)
        }
        
        if direction.contains(.right) {
            formUnion(.down)
        }
    }
}

extension UIPopoverArrowDirection {
    public init(_ direction: PopoverArrowDirection) {
        self.init()
        
        if direction.contains(.up) {
            formUnion(.up)
        }
        
        if direction.contains(.down) {
            formUnion(.down)
        }
        
        if direction.contains(.left) {
            formUnion(.down)
        }
        
        if direction.contains(.right) {
            formUnion(.down)
        }
    }
}
#endif
