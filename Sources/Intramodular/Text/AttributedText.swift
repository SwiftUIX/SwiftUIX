//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS)

public struct AttributedText: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    public typealias UIViewType = UILabel
    
    public let content: NSAttributedString
    
    public init(_ content: NSAttributedString) {
        self.content = content
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        .init()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.numberOfLines = 0
        uiView.attributedText = content
    }
}

#elseif os(macOS)

// TODO(@vmanot)

#endif
