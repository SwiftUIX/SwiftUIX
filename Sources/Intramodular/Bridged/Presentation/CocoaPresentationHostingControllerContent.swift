//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct CocoaPresentationHostingControllerContent: View  {
    var presentation: AnyModalPresentation
    
    init(presentation: AnyModalPresentation) {
        self.presentation = presentation
    }
    
    public var body: some View {
        presentation.content()
    }
}

#endif
