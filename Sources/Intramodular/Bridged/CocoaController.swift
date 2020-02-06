//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol opaque_CocoaController {
    var rootViewName: ViewName? { get }
    
    var presentationCoordinator: CocoaPresentationCoordinator { get }
    
    func present(_ presentation: AnyModalPresentation)
}

public protocol CocoaController: opaque_CocoaController, UIViewController {
    
}

#endif
