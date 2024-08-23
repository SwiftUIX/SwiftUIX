//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public enum _IfAvailable {
    @_documentation(visibility: internal)
public enum Available {
        case available
    }
    
    case `if`(Available)
}

@_documentation(visibility: internal)
public enum _SwiftUI_TargetPlatformType {
    case iOS
    case macOS
    case tvOS
    case visionOS
    case watchOS
}

#if os(iOS)
extension _SwiftUI_TargetPlatformType {
    public static var current: Self {
        Self.iOS
    }
}
#elseif os(macOS)
extension _SwiftUI_TargetPlatformType {
    public static var current: Self {
        Self.macOS
    }
}
#elseif os(tvOS)
extension _SwiftUI_TargetPlatformType {
    public static var current: Self {
        Self.tvOS
    }
}
#elseif os(visionOS)
extension _SwiftUI_TargetPlatformType {
    public static var current: Self {
        Self.visionOS
    }
}
#elseif os(watchOS)
extension _SwiftUI_TargetPlatformType {
    public static var current: Self {
        Self.watchOS
    }
}
#endif

@_documentation(visibility: internal)
public enum _SwiftUI_TargetPlatform {
    @_documentation(visibility: internal)
public enum iOS {
        case iOS
    }
    
    @_documentation(visibility: internal)
public enum macOS {
        case macOS
    }
    
    @_documentation(visibility: internal)
public enum tvOS {
        case tvOS
    }
    
    @_documentation(visibility: internal)
public enum visionOS {
        case visionOS
    }

    @_documentation(visibility: internal)
public enum watchOS {
        case watchOS
    }
}

@_documentation(visibility: internal)
public enum _TargetPlatformSpecific<Platform> {
    
}

extension _TargetPlatformSpecific where Platform == _SwiftUI_TargetPlatform.iOS {
    @_documentation(visibility: internal)
public enum NavigationBarItemTitleDisplayMode {
        case automatic
        case inline
        case large
    }
}

@_documentation(visibility: internal)
public struct _TargetPlatformConditionalModifiable<Root, Platform> {
    public typealias SpecificTypes = _TargetPlatformSpecific<_SwiftUI_TargetPlatform.iOS>
    
    public let root: Root
    
    fileprivate init(root: Root)  {
        self.root = root
    }

    public var body: Root {
        root
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension _TargetPlatformConditionalModifiable: Scene where Root: Scene {
    fileprivate init(@SceneBuilder root: () -> Root)  {
        self.init(root: root())
    }
}

extension _TargetPlatformConditionalModifiable: View where Root: View {
    fileprivate init(@ViewBuilder root: () -> Root)  {
        self.init(root: root())
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension Scene {
    public func modify<Modified: Scene>(
        for platform: _SwiftUI_TargetPlatform.iOS,
        @SceneBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.iOS>) -> Modified
    ) -> some Scene {
        modify(.init(root: self))
    }

    public func modify<Modified: Scene>(
        for platform: _SwiftUI_TargetPlatform.macOS,
        @SceneBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.macOS>) -> Modified
    ) -> some Scene {
        modify(.init(root: self))
    }
}

extension View {
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.iOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.iOS>) -> Modified
    ) -> some View {
        #if os(iOS)
        modify(.init(root: self))
        #else
        self
        #endif
    }
    
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.macOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.macOS>) -> Modified
    ) -> some View {
        #if os(macOS)
        modify(.init(root: self))
        #else
        self
        #endif
    }
    
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.tvOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.tvOS>) -> Modified
    ) -> some View {
        #if os(tvOS)
        modify(.init(root: self))
        #else
        self
        #endif
    }

    @ViewBuilder
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.watchOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.watchOS>) -> Modified
    ) -> some View {
        #if os(watchOS)
        modify(.init(root: self))
        #else
        self
        #endif
    }

    @ViewBuilder
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.visionOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.visionOS>) -> Modified
    ) -> some View {
        #if os(visionOS)
        modify(.init(root: self))
        #else
        self
        #endif
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Root: Scene, Platform == _SwiftUI_TargetPlatform.macOS {
    @SceneBuilder
    public func defaultSize(
        width: CGFloat,
        height: CGFloat
    ) -> some Scene {
        #if os(macOS)
        root.defaultSize(width: width, height: height)
        #else
        root
        #endif
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.iOS {
    @ViewBuilder
    public func navigationBarTitleDisplayMode(
        _ mode: SpecificTypes.NavigationBarItemTitleDisplayMode
    ) -> _TargetPlatformConditionalModifiable<some View, Platform> {
#if os(iOS)
        _TargetPlatformConditionalModifiable<_, Platform> {
            switch mode {
                case .automatic:
                    root.navigationBarTitleDisplayMode(.automatic)
                case .inline:
                    root.navigationBarTitleDisplayMode(.inline)
                case .large:
                    root.navigationBarTitleDisplayMode(.inline)
            }
        }
#else
        self
#endif
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.macOS {
    @ViewBuilder
    public func onExitCommand(
        perform action: (() -> Void)?
    ) -> some View {
#if os(macOS)
        root.onExitCommand(perform: action)
#else
        root
#endif
    }
}

@available(macOS 13.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.macOS {
    @ViewBuilder
    public func controlActiveState(
        _ state: _SwiftUI_TargetPlatform.macOS._ControlActiveState
    ) -> _TargetPlatformConditionalModifiable<some View, Platform> {
        #if os(macOS)
        _TargetPlatformConditionalModifiable<_, Platform> {
            self.environment(\.controlActiveState, .init(state))
        }
        #else
        _TargetPlatformConditionalModifiable<_, Platform> {
            self
        }
        #endif
    }
}

// MARK: - Auxiliary

extension _SwiftUI_TargetPlatform.macOS {
    @_documentation(visibility: internal)
public enum _ControlActiveState: Hashable, Sendable {
        case key
        case active
        case inactive
    }
}

#if os(macOS)
extension SwiftUI.ControlActiveState {
    public init(_ state: _SwiftUI_TargetPlatform.macOS._ControlActiveState) {
        switch state {
            case .key:
                self = .key
            case .active:
                self = .active
            case .inactive:
                self = .inactive
        }
    }
}

extension _SwiftUI_TargetPlatform.macOS._ControlActiveState {
    public init(_ state: SwiftUI.ControlActiveState) {
        switch state {
            case .key:
                self = .key
            case .active:
                self = .active
            case .inactive:
                self = .inactive
            default:
                assertionFailure()
                
                self = .inactive
        }
    }
}

extension EnvironmentValues {
    public var _SwiftUIX_controlActiveState: _SwiftUI_TargetPlatform.macOS._ControlActiveState {
        get {
            .init(controlActiveState)
        } set {
            controlActiveState = .init(newValue)
        }
    }
}
#else
extension EnvironmentValues {
    public var _SwiftUIX_controlActiveState: _SwiftUI_TargetPlatform.macOS._ControlActiveState {
        get {
            .active
        } set {
            // no op
        }
    }
}
#endif

#if swift(>=5.9)
extension View {
    @ViewBuilder
    public func _geometryGroup(_: _IfAvailable) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            geometryGroup()
        } else {
            self
        }
    }
}
#else
extension View {
    @ViewBuilder
    public func _geometryGroup(_: _IfAvailable) -> some View {
        self
    }
}
#endif
