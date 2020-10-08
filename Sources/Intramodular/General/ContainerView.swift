//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ContainerView: View {
    associatedtype Content: View
    
    init(@ViewBuilder content: () -> Content)
}
