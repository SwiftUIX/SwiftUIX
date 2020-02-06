//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EnvironmentalAnyView: View {
    private let base: AnyView
    private let baseType: ObjectIdentifier
    private var environment: EnvironmentBuilder
    
    public init<V: View>(_ view: V) {
        if let view = view as? EnvironmentalAnyView {
            self = view
        } else {
            self.base = view.eraseToAnyView()
            self.baseType = .init(type(of: view))
            self.environment = .init()
        }
    }
    
    public var body: some View {
        base.mergeEnvironmentBuilder(environment)
    }
}

extension EnvironmentalAnyView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environment.merge(builder) })
    }
}
