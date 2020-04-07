//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct ResultView<SuccessView: View, FailureView: View, Success, Failure: Error>: View {
    @usableFromInline
    let successView: SuccessView?
    
    @usableFromInline
    let failureView: FailureView?
    
    public init(
        _ result: Result<Success, Failure>,
        @ViewBuilder successView: @escaping (Success) -> SuccessView,
        @ViewBuilder failureView: @escaping (Failure) -> FailureView
    ) {
        switch result {
            case .success(let success):
                self.successView = successView(success)
                self.failureView = nil
            case .failure(let failure):
                self.successView = nil
                self.failureView = failureView(failure)
        }
    }
    
    @inlinable
    public var body: some View {
        Group {
            if successView != nil {
                successView!
            } else {
                failureView!
            }
        }
    }
}
