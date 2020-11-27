//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct FrameReader<Content: View>: View {
    public let content: Content
    
    public var body: some View {
        PreferenceReader(_NamedViewDescription.PreferenceKey.self) { description in
            content
        }
    }
}
