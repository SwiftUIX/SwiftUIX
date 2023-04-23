//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Applies a linear foreground gradient to the text.
    public func _foregroundLinearGradient(
        _ gradient: Gradient,
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> some View {
        overlay(
            LinearGradient(
                gradient: gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
        .mask(self)
    }

    public func _linearGradientOpacity(
        _ edges: Edge.Set,
        _ opacity: Double,
        inset: CGFloat
    ) -> AnyView {
        func calculateHorizontalSteps(
            proxy: GeometryProxy
        ) -> [Gradient.Stop] {
            var stops: [Gradient.Stop] = []
            
            if edges.contains(.leading) {
                stops += [
                    Gradient.Stop(color: Color.black.opacity(opacity), location: 0),
                    Gradient.Stop(color: Color.black, location: (inset / proxy.size.width)),
                ]
            }
            
            if edges.contains(.trailing) {
                stops += [
                    Gradient.Stop(color: Color.black, location: 1 - (inset / proxy.size.width)),
                    Gradient.Stop(color: Color.black.opacity(opacity), location: 1.0),
                ]
            }
            
            return stops
        }
        
        func calculateVerticalStops(
            proxy: GeometryProxy
        ) -> [Gradient.Stop] {
            var stops: [Gradient.Stop] = []
            
            if edges.contains(.top) {
                stops += [
                    Gradient.Stop(color: Color.black.opacity(opacity), location: 0),
                    Gradient.Stop(color: Color.black, location: (inset / proxy.size.height))
                ]
            }
            
            if edges.contains(.bottom) {
                stops += [
                    Gradient.Stop(color: Color.black, location: 1 - (inset / proxy.size.height)),
                    Gradient.Stop(color: Color.black.opacity(opacity), location: 1.0),
                ]
            }
            
            return stops
        }

        func horizontalGradient(proxy: GeometryProxy) -> LinearGradient {
            LinearGradient(
                gradient: Gradient(stops: calculateHorizontalSteps(proxy: proxy)),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        func verticalGradient(proxy: GeometryProxy) -> LinearGradient {
            LinearGradient(
                gradient: Gradient(stops: calculateVerticalStops(proxy: proxy)),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        return mask {
            GeometryReader { proxy in
                if edges.contains(.leading) || edges.contains(.trailing) {
                    if edges.contains(.top) || edges.contains(.bottom) {
                        horizontalGradient(proxy: proxy).mask {
                            verticalGradient(proxy: proxy)
                        }
                    } else {
                        horizontalGradient(proxy: proxy)
                    }
                } else if edges.contains(.top) || edges.contains(.bottom) {
                    verticalGradient(proxy: proxy)
                } else {
                    Color.black
                }
            }
            .eraseToAnyView()
        }
        .eraseToAnyView()
    }
}
