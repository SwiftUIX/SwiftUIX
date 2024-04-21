//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// https://raw.githubusercontent.com/nathantannar4/Turbocharger/52f22b97dcefed06e274d66ccba0f659f8eefbd5/Sources/Turbocharger/Sources/Extensions/Image%2BExtensions.swift
@_spi(Internal)
public enum _SwiftUI_ImageProvider {
    case system(String)
    case named(String, Bundle?)
    case cgImage(CGImage, CGFloat, Image.Orientation)
    case appKitOrUIKitImage(Image._AppKitOrUIKitType)
    
    init?(for image: Image) {
        guard let base = Mirror(reflecting: image).descendant("provider", "base") else {
            return nil
        }
        
        let className = String(describing: type(of: base))
        let mirror = Mirror(reflecting: base)
        
        switch className {
            case "NamedImageProvider": do {
                guard let name = mirror.descendant("name") as? String else {
                    return nil
                }
                
                if let location = mirror.descendant("location") {
                    if String(describing: location) == "system" {
                        self = .system(name)
                    } else {
                        let bundle = mirror.descendant("location", "bundle")
                        self = .named(name, bundle as? Bundle)
                    }
                } else {
                    self = .named(name, nil)
                }
            }
            case "\(Image._AppKitOrUIKitType.self)": do {
                guard let image = base as? Image._AppKitOrUIKitType else {
                    return nil
                }
                self = .appKitOrUIKitImage(image)
            }
            case "CGImageProvider": do {
                guard
                    let image = mirror.descendant("image"),
                    let scale = mirror.descendant("scale") as? CGFloat,
                    let orientation = mirror.descendant("orientation") as? Image.Orientation
                else {
                    return nil
                }
                self = .cgImage(image as! CGImage, scale, orientation)
            }
            default:
                return nil
        }
    }
    
    func resolved(in environment: EnvironmentValues) -> Image._AppKitOrUIKitType? {
        switch self {
            case .system(let name): do {
#if os(iOS) || os(tvOS) || os(watchOS)
                let scale: UIImage.SymbolScale = {
                    guard let scale = environment.imageScale else { return .unspecified }
                    switch scale {
                        case .small: return .small
                        case .medium: return .medium
                        case .large: return .large
                        @unknown default:
                            return .unspecified
                    }
                }()
                let config = environment.font?.toUIFont().map {
                    UIImage.SymbolConfiguration(
                        font: $0,
                        scale: scale
                    )
                } ?? UIImage.SymbolConfiguration(scale: scale)
                return UIImage(
                    systemName: name,
                    withConfiguration: config
                )
#elseif os(macOS)
                if #available(macOS 11.0, *) {
                    return NSImage(systemSymbolName: name, accessibilityDescription: nil)
                }
                return nil
#endif
            }
            case let .named(name, bundle): do {
#if os(iOS) || os(tvOS) || os(watchOS)
                return UIImage(named: name, in: bundle, with: nil)
#elseif os(macOS)
                if #available(macOS 14.0, *), let bundle {
                    return NSImage(resource: ImageResource(name: name, bundle: bundle))
                }
                return NSImage(named: name)
#endif
            }
            case let .appKitOrUIKitImage(image):
                return image
            case let .cgImage(image, scale, orientation): do {
#if os(iOS) || os(tvOS) || os(watchOS)
                let orientation: UIImage.Orientation = {
                    switch orientation {
                        case .down: return .down
                        case .downMirrored: return .downMirrored
                        case .left: return .left
                        case .leftMirrored: return .leftMirrored
                        case .right: return .right
                        case .rightMirrored: return .rightMirrored
                        case .up: return .up
                        case .upMirrored: return .upMirrored
                    }
                }()
                return UIImage(cgImage: image, scale: scale, orientation: orientation)
#elseif os(macOS)
                return NSImage(cgImage: image, size: .zero)
#endif
            }
        }
    }
}
