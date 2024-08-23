//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public struct _TryCatchView<Content: View, RecoveryContent: View>: View {
    let content: () throws ->  Content
    let recovery: (Error) -> RecoveryContent
    
    public init(
        @ViewBuilder content: @escaping () throws -> Content,
        @ViewBuilder recover: @escaping (Error) -> RecoveryContent
    ) {
        self.content = content
        self.recovery = recover
    }
    
    public init(
        @ViewBuilder content: @escaping () throws -> Content,
        @ViewBuilder recover: @escaping () -> RecoveryContent
    ) {
        self.content = content
        self.recovery = { _ in recover() }
    }
    
    public var body: some View {
        ResultView(
            success: {
                try content()
            },
            failure: {
                recovery($0)
            }
        )
    }
}
