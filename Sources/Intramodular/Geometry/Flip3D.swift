//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct Flip3DGeometryEffect: GeometryEffect {
    var animatableData: Double {
        get {
            angle
        } set {
            angle = newValue
        }
    }
    
    var angle: Double
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let a = CGFloat(Angle(degrees: angle).radians)
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.0005
        
        transform = CATransform3DTranslate(transform, size.width / 2, 0, 0)
        transform = CATransform3DRotate(transform, a, 0, 1, 0)
        transform = CATransform3DTranslate(transform, -size.width / 2, 0, 0)
        
        return ProjectionTransform(transform)
    }
}

#endif

struct Flip3D<Reverse: View>: ViewModifier {
    @Binding private var isFlipped: Bool
    
    private let reverse: Reverse
    private let axis: Axis3D
    
    init(reverse: Reverse, axis: Axis3D, isFlipped: Binding<Bool>) {
        self.reverse = reverse
        self.axis = axis
        self._isFlipped = isFlipped
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .hidden(isFlipped)
            reverse
                .mirrored3D(for: axis)
                .hidden(!isFlipped)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: axis)
    }
}

// MARK: - Helpers -

extension View {
    public func flip3D<Reverse: View>(reverse: Reverse, axis: Axis3D = .y, isFlipped: Binding<Bool>) -> some View {
        modifier(Flip3D(reverse: reverse, axis: axis, isFlipped: isFlipped))
    }
}
