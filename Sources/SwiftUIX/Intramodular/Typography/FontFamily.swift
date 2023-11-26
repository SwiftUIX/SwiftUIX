//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A font family.
public protocol FontFamily: CaseIterable, RawRepresentable {
    var rawValue: String { get }
    
    /// The font weight that corresponds to this font.
    var weight: Font.Weight? { get }
}

// MARK: - API

extension FontFamily {
    public func callAsFunction(size: CGFloat) -> Font {
        Font.custom(rawValue, size: size)
    }
}

extension Font {
    public static func custom<F: FontFamily>(_ family: F.Type, size: CGFloat, weight: Weight) -> Font {
        guard let font = family.allCases.first(where: { $0.weight == weight }) else {
            assertionFailure("The font family \(family) does not support \(weight) as a valid weight")
            
            return Font.system(size: size, weight: weight)
        }
        
        return custom(font.rawValue, size: size)
    }
    
    #if canImport(UIKit)
    public static func custom<F: FontFamily>(_ family: F.Type, style: Font.TextStyle) -> Font {
        let metrics = style.defaultMetrics
        
        return .custom(family, size: metrics.size, weight: metrics.weight)
    }
    #endif
}

extension Text {
    /// Sets the default font for text in the view.
    public func font<F: FontFamily>(_ font: F, size: CGFloat) -> Text {
        self.font(.custom(font.rawValue, size: size))
    }
}

extension View {
    /// Sets the default font for text in this view.
    public func font<F: FontFamily>(_ font: F, size: CGFloat) -> some View {
        self.font(.custom(font.rawValue, size: size))
    }
    
    #if os(iOS)
    /// Sets the default font for text in this view.
    public func font<F: FontFamily>(
        _ font: F,
        size: CGFloat,
        lineHeight: CGFloat
    ) -> some View {
        modifier(SetFontWithLineHeight(font: font, fontSize: size, lineHeight: lineHeight))
    }
    #endif
}

#if os(iOS) && canImport(CoreTelephony)
extension CocoaTextField {
    /// Sets the default font for text in the view.
    public func font<F: FontFamily>(_ font: F, size: CGFloat) -> Self {
        self.font(AppKitOrUIKitFont(name: font.rawValue, size: size))
    }
}

extension TextView {
    /// Sets the default font for text in the view.
    public func font<F: FontFamily>(_ font: F, size: CGFloat) -> Self {
        self.font(AppKitOrUIKitFont(name: font.rawValue, size: size))
    }
}
#endif

// MARK: - Auxiliary

#if os(iOS)
fileprivate struct SetFontWithLineHeight<F: FontFamily>: ViewModifier {
    let font: F
    let fontSize: CGFloat
    let lineHeight: CGFloat
    
    @State private var cachedAppKitOrUIKitFont: AppKitOrUIKitFont?
    @State private var cachedLineSpacing: CGFloat?
    
    private var appKitOrUIKitFont: AppKitOrUIKitFont? {
        cachedAppKitOrUIKitFont ?? AppKitOrUIKitFont(name: font.rawValue, size: fontSize)
    }
    
    private var lineSpacing: CGFloat? {
        guard let appKitOrUIKitFont = appKitOrUIKitFont else {
            return nil
        }
        
        return cachedLineSpacing ?? (lineHeight - appKitOrUIKitFont.lineHeight)
    }
    
    func body(content: Content) -> some View {
        if let appKitOrUIKitFont = appKitOrUIKitFont, let lineSpacing = lineSpacing {
            content
                .font(font, size: fontSize)
                .lineSpacing(lineSpacing)
                .padding(.vertical, lineSpacing / 2)
                .onAppear {
                    withoutAnimation {
                        cachedAppKitOrUIKitFont = appKitOrUIKitFont
                        cachedLineSpacing = lineSpacing
                    }
                }
        } else {
            content
                .font(font, size: fontSize)
        }
    }
}
#endif

#if os(macOS)
extension NSFont {
    public convenience init?<F: FontFamily>(_ family: F, size: CGFloat) {
        self.init(name: family.rawValue, size: size)!
    }
}
#endif
