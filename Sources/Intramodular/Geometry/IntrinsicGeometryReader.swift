//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct IntrinsicGeometryProxy {
    public let containerOriginInGlobal: CGPoint
    public let frame: CGRect?
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
    
    private let makeContent: (IntrinsicGeometryProxy) -> Content
    
    public init(@ViewBuilder _ makeContent: @escaping (IntrinsicGeometryProxy) -> Content) {
        self.makeContent = makeContent
    }
    
    @State var frame: CGRect?
    
    public var body: some View {
        GeometryReader { geometry in
            self.makeContent(.init(containerOriginInGlobal: geometry.frame(in: .global).origin, frame: self.frame)).anchorPreference(key: Preferences.Key.self, value: .bounds) {
                .init(bounds: $0)
            }
            .backgroundPreferenceValue(Preferences.Key.self) { value -> EmptyView in
                guard let value = value else {
                    return EmptyView()
                }
                
                DispatchQueue.main.async {
                    self.frame = geometry[value.bounds]
                }
                
                return EmptyView()
            }
        }
    }
}
