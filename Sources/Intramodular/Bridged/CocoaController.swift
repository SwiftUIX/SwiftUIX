//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol opaque_CocoaController {

}

public protocol CocoaController: opaque_CocoaController, UIViewController {
    
}

#endif
