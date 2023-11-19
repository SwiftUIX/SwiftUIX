//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import UIKit

extension UITableViewController {
    public var indexPathsForVisibleRows: [IndexPath]? {
        tableView.indexPathsForVisibleRows
    }
}

#endif
