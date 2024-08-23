//
// Copyright (c) Vatsal Manot
//

import Swift

#if canImport(AppKit)

@_documentation(visibility: internal)
public enum AppKitOrUIKitBackgroundFetchResult {
    case newData
    case noData
    case failed
}

#elseif canImport(WatchKit)

@_documentation(visibility: internal)
public enum AppKitOrUIKitBackgroundFetchResult {
    case newData
    case noData
    case failed
}

#else

import UIKit

public typealias AppKitOrUIKitBackgroundFetchResult = UIBackgroundFetchResult

#endif
