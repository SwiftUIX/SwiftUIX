//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct IntrinsicGeometryProxy {
    public let frame: CGRect?
    
    public var estimatedFrame: CGRect {
        return frame ?? .zero
    }
}

/// A container view that recursively defines its content as a function of the content's size and coordinate space.
public struct IntrinsicGeometryReader<Content: View>: View {
    fileprivate struct Preferences {
        fileprivate struct Key: PreferenceKey {
            typealias Value = Optional<Preferences>
            
            static var defaultValue: Value {
                return nil
            }
            
            static func reduce(value: inout Value, nextValue: () -> Value) {
                value = nextValue() ?? value
            }
        }
        
        let bounds: Anchor<CGRect>
    }
    
    private let content: (IntrinsicGeometryProxy) -> Content
    
    public init(@ViewBuilder _ content: @escaping (IntrinsicGeometryProxy) -> Content) {
        self.content = content
    }
    
    @DelayedState var frame: CGRect?
    
    public var body: some View {
        Group {
            self.content(.init(frame: self.frame))
                .anchorPreference(key: Preferences.Key.self, value: .bounds) {
                    .init(bounds: $0)
            }
        }
        .backgroundPreferenceValue(Preferences.Key.self) { value in
            GeometryReader { geometry in
                ZStack {
                    Color.clear.then { _ in
                        self.frame = value.map({ geometry[$0.bounds] })
                    }
                }
                .frame(width: .infinity, height: .infinity)
            }
        }
    }
}
