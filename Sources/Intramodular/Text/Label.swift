//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct Label: AppKitOrUIKitViewRepresentable {
    @Environment(\.font) private var font
    
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitLabel
    
    private var text: String
    
    public init(_ text: String) {
        self.text = text
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        AppKitOrUIKitViewType().then {
            $0.font = font?.toUIFont()
            $0.text = text
        }
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        view.font = font?.toUIFont()
        view.text = text
    }
}

#endif
