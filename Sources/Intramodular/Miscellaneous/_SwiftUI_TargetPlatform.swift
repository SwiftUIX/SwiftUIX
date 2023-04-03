//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public enum _SwiftUI_TargetPlatform {
    public enum iOS {
        case iOS
    }
    
    public enum macOS {
        case macOS
    }
    
    public enum tvOS {
        case tvOS
    }
    
    public enum watchOS {
        case watchOS
    }
}

public enum _TargetPlatformSpecific<Platform> {
    
}

extension _TargetPlatformSpecific where Platform == _SwiftUI_TargetPlatform.iOS {
    public enum NavigationBarItemTitleDisplayMode {
        case automatic
        case inline
        case large
    }
}

public struct _TargetPlatformConditionalModifiable<Root: View, Platform>: View {
    public typealias SpecificTypes = _TargetPlatformSpecific<_SwiftUI_TargetPlatform.iOS>
    
    public let root: Root
    
    fileprivate init(@ViewBuilder root: () -> Root) {
        self.root = root()
    }
    
    public var body: some View {
        root
    }
}

extension View {
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.iOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.iOS>) -> Modified
    ) -> some View {
        modify(.init(root: { self }))
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Platform == _SwiftUI_TargetPlatform.iOS {
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
