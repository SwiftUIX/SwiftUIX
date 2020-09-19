//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI
import UniformTypeIdentifiers

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct FileImportLink<Label: View>: View {
    private let allowedContentTypes: [UTType]
    private let onCompletion: (Result<URL, Error>) -> Void
    private let label: Label
    
    @State var isPresented: Bool = false
    
    public init(
        allowedContentTypes: [UTType],
        onCompletion: @escaping (Result<URL, Error>) -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.allowedContentTypes = allowedContentTypes
        self.onCompletion = onCompletion
        self.label = label()
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        allowedContentTypes: [UTType],
        onCompletion: @escaping (Result<URL, Error>) -> Void
    ) where Label == Text {
        self.init(
            allowedContentTypes: allowedContentTypes,
            onCompletion: onCompletion
        ) {
            Text(title)
        }
    }
    
    public var body: some View {
        Button(toggle: $isPresented) {
            label.fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: allowedContentTypes,
                onCompletion: onCompletion
            )
        }
    }
}
