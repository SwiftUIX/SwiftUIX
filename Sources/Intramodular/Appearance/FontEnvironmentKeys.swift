//
// Copyright (c) Vatsal Manot
//

import SwiftUI

fileprivate struct FontEnvironmentKeys {
    struct LargeTitle: EnvironmentKey {
        public static var defaultValue: Font = .largeTitle
    }
    
    struct Title: EnvironmentKey {
        public static var defaultValue: Font = .largeTitle
    }
    
    struct Headline: EnvironmentKey {
        public static var defaultValue: Font = .headline
    }
    
    struct Subheadline: EnvironmentKey {
        public static var defaultValue: Font = .subheadline
    }
    
    struct Body: EnvironmentKey {
        public static var defaultValue: Font = .body
    }
    
    struct Callout: EnvironmentKey {
        public static var defaultValue: Font = .callout
    }
    
    struct Footnote: EnvironmentKey {
        public static var defaultValue: Font = .footnote
    }
    
    struct Caption: EnvironmentKey {
        public static var defaultValue: Font = .caption
    }
}

extension EnvironmentValues {
    public var largeTitleFont: Font {
        get {
            self[FontEnvironmentKeys.LargeTitle]
        } set {
            self[FontEnvironmentKeys.LargeTitle] = newValue
        }
    }
    
    public var titleFont: Font {
        get {
            self[FontEnvironmentKeys.Title]
        } set {
            self[FontEnvironmentKeys.Title] = newValue
        }
    }
    
    public var headlineFont: Font {
        get {
            self[FontEnvironmentKeys.Headline]
        } set {
            self[FontEnvironmentKeys.Headline] = newValue
        }
    }
    
    public var subheadlineFont: Font {
        get {
            self[FontEnvironmentKeys.Subheadline]
        } set {
            self[FontEnvironmentKeys.Subheadline] = newValue
        }
    }
    
    public var bodyFont: Font {
        get {
            self[FontEnvironmentKeys.Body]
        } set {
            self[FontEnvironmentKeys.Body] = newValue
        }
    }
    
    public var calloutFont: Font {
        get {
            self[FontEnvironmentKeys.Callout]
        } set {
            self[FontEnvironmentKeys.Callout] = newValue
        }
    }
    
    public var footnoteFont: Font {
        get {
            self[FontEnvironmentKeys.Footnote]
        } set {
            self[FontEnvironmentKeys.Footnote] = newValue
        }
    }
    
    public var captionFont: Font {
        get {
            self[FontEnvironmentKeys.Caption]
        } set {
            self[FontEnvironmentKeys.Caption] = newValue
        }
    }
}

extension View {
    public func largeTitleFont(_ font: Font) -> some View {
        environment(\.largeTitleFont, font)
    }
    
    public func titleFont(_ font: Font) -> some View {
        environment(\.titleFont, font)
    }
    
    public func headlineFont(_ font: Font) -> some View {
        environment(\.headlineFont, font)
    }
    
    public func subheadlineFont(_ font: Font) -> some View {
        environment(\.subheadlineFont, font)
    }
    
    public func bodyFont(_ font: Font) -> some View {
        environment(\.bodyFont, font)
    }
    
    public func calloutFont(_ font: Font) -> some View {
        environment(\.calloutFont, font)
    }
    
    public func footnoteFont(_ font: Font) -> some View {
        environment(\.footnoteFont, font)
    }
    
    public func captionFont(_ font: Font) -> some View {
        environment(\.captionFont, font)
    }
}
