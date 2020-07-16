//
// Copyright (c) Vatsal Manot
//

import CoreData
import Swift
import SwiftUI

extension View {
    @inlinable
    public func environment(_ newEnvironment: EnvironmentValues) -> some View {
        transformEnvironment(\.self) { environment in
            environment = newEnvironment
        }
    }
    
    @inlinable
    public func managedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> some View {
        environment(\.managedObjectContext, managedObjectContext)
    }
}
