//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol ContainerView: View {
    associatedtype Content
    
    init(@ViewBuilder content: () -> Content)
}
