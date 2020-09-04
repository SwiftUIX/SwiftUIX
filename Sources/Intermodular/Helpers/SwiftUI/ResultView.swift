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
    
    public init(
        _ result: Result<Success, Failure>,
        @ViewBuilder success: @escaping (Success) -> SuccessView,
        @ViewBuilder failure: @escaping (Failure) -> FailureView
    ) {
        switch result {
            case .success(let value):
                self.successView = success(value)
                self.failureView = nil
            case .failure(let error):
                self.successView = nil
                self.failureView = failure(error)
        }
    }
    
    public init?(
        _ result: Result<Success, Failure>?,
        @ViewBuilder success: @escaping (Success) -> SuccessView,
        @ViewBuilder failure: @escaping (Failure) -> FailureView
    ) {
        guard let result = result else {
            return nil
        }
        
        self.init(result, success: success, failure: failure)
    }
    
    public init(
        _ result: Result<Success, Failure>,
        @ViewBuilder success: @escaping (Success) -> SuccessView,
        @ViewBuilder failure: @escaping () -> FailureView
    ) {
        self.init(result, success: success, failure: { _ in failure() })
    }
    
    public init?(
        _ result: Result<Success, Failure>?,
        @ViewBuilder success: @escaping (Success) -> SuccessView,
        @ViewBuilder failure: @escaping () -> FailureView
    ) {
        guard let result = result else {
            return nil
        }
        
        self.init(result, success: success, failure: failure)
    }
}

extension ResultView where Success == Void, Failure == Error {
    public init(successView: () throws -> SuccessView, failureView: (Error) -> FailureView) {
        do {
            self.successView = try successView()
            self.failureView = nil
        } catch {
            self.successView = nil
            self.failureView = failureView(error)
        }
    }
}
