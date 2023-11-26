//
// Copyright (c) Vatsal Manot
//

import CoreData
import Swift
import SwiftUI

#if canImport(UIKit)

import UIKit

extension FetchedResults {
    public subscript(_ indexSet: IndexSet) -> [Result] {
        indexSet.map({ self[$0] })
    }
}

#endif
