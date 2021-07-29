//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum UserInterfaceIdiom: Hashable {
    case carPlay
    case mac
    case phone
    case pad
    case tv
    case watch
    
    case unspecified
    
    public static var current: UserInterfaceIdiom {
        #if targetEnvironment(macCatalyst)
        return .mac
        #elseif os(iOS) || os(tvOS)
        switch UIDevice.current.userInterfaceIdiom {
            case .carPlay:
                return .carPlay
            case .phone:
                return .phone
            case .pad:
                return .pad
            case .tv:
                return .tv
            #if swift(>=5.3)
            case .mac:
                return .mac
            #endif
            case .unspecified:
                return .unspecified
                
            @unknown default:
                return .unspecified
        }
        #elseif os(macOS)
        return .mac
        #elseif os(watchOS)
        return .watch
        #endif
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    public var userInterfaceIdiom: UserInterfaceIdiom {
        get {
            self[DefaultEnvironmentKey<UserInterfaceIdiom>.self] ?? .current
        } set {
            self[DefaultEnvironmentKey<UserInterfaceIdiom>.self] = newValue
        }
    }
}
