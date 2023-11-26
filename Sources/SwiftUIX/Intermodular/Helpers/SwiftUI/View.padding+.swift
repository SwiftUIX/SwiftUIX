//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The relative amount of padding, to be used with `View/padding(_:_:)`.
///
/// **Do not** reference this type directly.
public enum _RelativePaddingAmount: CaseIterable, Hashable {
    case extraSmall
    case small
    case regular
    case large
    case extraLarge
    case extraExtraLarge
}

extension View {
    /// A view that pads this view inside the specified edge insets with a
    /// system-calculated amount of padding.
    ///
    /// Use `padding(_:)` to add a system-calculated amount of padding inside
    /// one or more of the view's edges by passing either a single edge name, or
    /// an `OptionSet` describing which edges should be padded. For example you
    /// can add padding to the bottom of a text view:
    ///
    /// - Parameters:
    ///   - edges: The set of edges along which to pad this view; if `nil` the
    ///     specified or system-calculated mount is applied to all edges.
    ///   - amount: The amount to inset this view on the specified edges. If
    ///     `nil`, the amount is the system-default amount.
    ///
    /// - Returns: A view that pads this view using the specified edge insets
    ///   with specified amount of padding.
    @ViewBuilder
    public func padding(
        _ edges: Edge.Set,
        _ amount: _RelativePaddingAmount?
    ) -> some View {
        switch amount {
            case .none:
                padding(edges)
            case .some(.extraSmall):
                #if os(iOS)
                padding(edges, 4)
                #elseif os(watchOS)
                padding(edges, 2)
                #else
                padding(edges, 4)
                #endif
            case .some(.small):
                #if os(iOS)
                padding(edges, 8)
                #elseif os(watchOS)
                padding(edges, 4)
                #else
                padding(edges, 8)
                #endif
            case .some(.regular):
                padding(edges)
            case .some(.large):
                padding(edges).padding(edges)
            case .some(.extraLarge):
                padding(edges).padding(edges).padding(edges)
            case .some(.extraExtraLarge):
                padding(edges).padding(edges).padding(edges).padding(edges)
        }
    }
    
    public func padding(
        _ amount: _RelativePaddingAmount?
    ) -> some View {
        padding(.all, amount)
    }
    
    public func padding(
        horizontal: _RelativePaddingAmount,
        vertical: _RelativePaddingAmount
    ) -> some View {
        padding(.horizontal, horizontal).padding(.vertical, vertical)
    }
}

// MARK: - Helpers

@available(iOS 15.0, macOS 10.15, watchOS 9.0, *)
@available(tvOS, unavailable)
extension ControlSize {
    public func _mapRankToRelativePadding() -> _RelativePaddingAmount {
        switch self {
            case .mini:
                return .extraSmall
            case .small:
                return .small
            case .regular:
                return .regular
            case .large:
                return .large
            default:
                assertionFailure()
                
                return .regular
        }
    }
}
