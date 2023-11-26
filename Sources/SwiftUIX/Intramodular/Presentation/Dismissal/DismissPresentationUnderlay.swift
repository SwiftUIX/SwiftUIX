//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct DismissPresentationUnderlay<Content: View>: View {
    @Environment(\.presentationManager) var presentationManager
    
    public let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        #if !os(tvOS)
        return GeometryReader(alignment: .center) { proxy in
            self.content
        }
        .background(
            Color.almostClear.onTapGesture {
                self.presentationManager.dismiss()
            }
        )
        #else
        return GeometryReader { proxy in
            self.content
        }
        #endif
    }
}
