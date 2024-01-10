//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

extension CocoaList {
    public func _overridePreferences(
        _ preferences: _CocoaListPreferences
    ) -> Self {
        then {
            $0._cocoaListPreferences = preferences
        }
    }
    
    public func _overridePreferences(
        _ operation: (inout _CocoaListPreferences) -> Void
    ) -> Self {
        then {
            operation(&$0._cocoaListPreferences)
        }
    }
}

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)
extension CocoaList {
    public func listStyle(_ style: UITableView.Style) -> Self {
        then({ $0.style = style })
    }
}

#if !os(tvOS)
extension CocoaList {
    public func listSeparatorStyle(
        _ separatorStyle: UITableViewCell.SeparatorStyle
    ) -> Self {
        then({ $0.separatorStyle = separatorStyle })
    }
}
#endif

extension CocoaList {
    public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        then({ $0.scrollViewConfiguration.alwaysBounceVertical = alwaysBounceVertical })
    }
    
    public func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        then({ $0.scrollViewConfiguration.alwaysBounceHorizontal = alwaysBounceHorizontal })
    }
    
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
    
    public func contentInsets(_ contentInset: EdgeInsets) -> Self {
        then({ $0.scrollViewConfiguration.contentInset = contentInset })
    }
    
    @_disfavoredOverload
    public func contentInsets(_ insets: UIEdgeInsets) -> Self {
        contentInsets(EdgeInsets(insets))
    }
    
    public func contentInsets(
        _ edges: Edge.Set = .all,
        _ length: CGFloat = 0
    ) -> Self {
        contentInsets(EdgeInsets(edges, length))
    }
    
    public func contentOffset(_ contentOffset: Binding<CGPoint>) -> Self {
        then({ $0.scrollViewConfiguration.contentOffset = contentOffset })
    }
}

@available(tvOS, unavailable)
extension CocoaList {
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
    
    public func refreshControlTintColor(_ color: UIColor?) -> Self {
        then({ $0.scrollViewConfiguration.refreshControlTintColor = color })
    }
}
#endif

#endif
