//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Cocoa
import Swift
import SwiftUI

/**
 A view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
 
 The appearance of labels is configurable, and they can display attributed strings, allowing you to customize the appearance of substrings within a label. You can add labels to your interface programmatically or by using Interface Builder.
 
 The following steps are required to add a label to your interface:
 
 * Supply either a string or an attributed string that represents the content.
 
 * If using a nonattributed string, configure the appearance of the label.
 
 * Set up Auto Layout rules to govern the size and position of the label in your interface.
 
 * Provide accessibility information and localized strings.
 */
@IBDesignable
open class NSLabel: NSView {
    private let defaultBackgroundColor = NSColor.clear
    
    /**
     The current text that is displayed by the label.
     
     This property is nil by default. Assigning a new value to this property also replaces the value of the attributedText property with the same text without any inherent style attributes, instead the label styles the new string using shadowColor, textAlignment, and other style-related properties of the class.
     */
    @IBInspectable
    public var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    /**
     The current styled text that is displayed by the label.
     
     This property is nil by default. Assigning a new value to this property also replaces the value of the text property with the same string data, although without any formatting information. In addition, assigning a new a value updates the values in the font, textColor, and other style-related properties so that they reflect the style information starting at location 0 in the attributed string.
     */
    @IBInspectable
    public var attributedText: NSAttributedString? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    /**
     The font used to display the text.
     
     If you are not using styled text, this property applies to the entire text string in the text property.
     */
    @IBInspectable
    public var font: NSFont
    
    /**
     The color of the text.
     
     If you are not using styled text, this property applies to the entire text string in the text property.
     
     The default value for this property is the default text color for the system appearance state (set through the textColor class property of NSColor).
     */
    @IBInspectable
    public var textColor: NSColor
    
    /**
     The view’s background color.
     The default value is nil, which results in a transparent background color.
     */
    @IBInspectable
    public var backgroundColor: NSColor
    
    /**
     The technique to use for aligning the text.
     
     If you are not using styled text, this property applies to the entire text string in the text property.
     
     In macOS 10.11 and later, the default value of this property is NSTextAlignment.natural; prior to macOS 10.11, the default value is NSTextAlignment.left.
     */
    @IBInspectable
    public var textAlignment: NSTextAlignment {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    /**
     The technique to use for wrapping and truncating the label’s text.
     
     This property is set to NSLineBreakMode.byTruncatingTail by default.
     */
    @IBInspectable
    public var lineBreakMode: NSLineBreakMode {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    /**
     A Boolean value indicating whether the font size should be reduced in order to fit the title string into the label’s bounding rectangle.
     
     This feature is yet to be implemented
     */
    @IBInspectable
    public var adjustsFontSizeToFitWidth: Bool
    
    /**
     The minimum scale factor supported for the label’s text.
     
     This feature is yet to be implemented
     */
    @IBInspectable
    public var minimumScaleFactor: CGFloat
    
    /**
     The maximum number of lines to use for rendering text.
     
     This property controls the maximum number of lines to use in order to fit the label’s text into its bounding rectangle. The default value for this property is 1. To remove any maximum limit, and use as many lines as needed, set the value of this property to 0.
     
     If you constrain your text using this property, any text that does not fit within the maximum number of lines and inside the bounding rectangle of the label is truncated using the appropriate line break mode, as specified by the lineBreakMode property.
     */
    @IBInspectable
    public var numberOfLines: Int
    
    /**
     The highlight color applied to the label’s text.
     
     This color is applied to the label automatically whenever the isHighlighted property is set to true.
     
     The default value of this property is nil.
     */
    @IBInspectable
    public var highlightedTextColor: NSColor?
    
    /**
     A boolean value indicating whether the label should be drawn with a highlight.
     
     In order for the highlight to be drawn, the highlightedTextColor property must contain a non-nil value.
     
     The default value of this property is false.
     */
    @IBInspectable
    public var isHighlighted: Bool
    
    /**
     The shadow color of the text.
     
     The default value for this property is nil, which indicates that no shadow is drawn. In addition to this property, you may also want to change the default shadow offset by modifying the shadowOffset property. Text shadows are drawn with the specified offset and color and no blurring.
     */
    @IBInspectable
    public var shadowColor: NSColor?
    
    /**
     The shadow offset (measured in points) for the text.
     
     The shadow color must be non-nil for this property to have any effect. The default offset size is (0, -1), which indicates a shadow one point above the text. Text shadows are drawn with the specified offset and color and no blurring.
     */
    @IBInspectable
    public var shadowOffset: CGSize
    
    /**
     The preferred maximum width (in points) for a multiline label.
     
     This property affects the size of the label when layout constraints are applied to it. During layout, if the text extends beyond the width specified by this property, the additional text flows to one or more new lines, increasing the height of the label.
     */
    public var preferredMaxLayoutWidth: CGFloat
    
    private var drawingRect = NSRect.zero
    
    override init(frame frameRect: NSRect) {
        self.font = NSFont.labelFont(ofSize: 12.0)
        self.textColor = NSColor.textColor
        self.backgroundColor = defaultBackgroundColor
        self.numberOfLines = 1
        
        if #available(OSX 10.11, *) {
            self.textAlignment = NSTextAlignment.natural
        } else {
            self.textAlignment = NSTextAlignment.left
        }
        
        self.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.adjustsFontSizeToFitWidth = false
        self.minimumScaleFactor = 0
        self.isHighlighted = false
        self.shadowOffset = CGSize(width: 0, height: -1)
        self.preferredMaxLayoutWidth = 0
        
        super.init(frame: frameRect)
    }
    
    required public init?(coder decoder: NSCoder) {
        if let text = decoder.decodeObject(forKey: "font") as? String {
            self.text = text
        }
        
        if let attributedText = decoder.decodeObject(forKey: "attributedText") as? NSAttributedString {
            self.attributedText = attributedText
        }
        
        self.font = decoder.decodeObject(forKey: "font") as! NSFont
        self.textColor = decoder.decodeObject(forKey: "textColor") as! NSColor
        self.backgroundColor = decoder.decodeObject(forKey: "backgroundColor") as! NSColor
        
        if let textAlignment = decoder.decodeObject(forKey: "textAlignment") as? NSTextAlignment {
            self.textAlignment = textAlignment
        } else if #available(OSX 10.11, *) {
            self.textAlignment = NSTextAlignment.natural
        } else {
            self.textAlignment = NSTextAlignment.left
        }
        
        if let lineBreakMode = decoder.decodeObject(forKey: "lineBreakMode") as? NSLineBreakMode {
            self.lineBreakMode = lineBreakMode
        } else {
            self.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
        
        self.adjustsFontSizeToFitWidth = decoder.decodeObject(forKey: "adjustsFontSizeToFitWidth") as! Bool
        self.minimumScaleFactor = decoder.decodeObject(forKey: "minimumScaleFactor") as! CGFloat
        
        if let numberOfLines = decoder.decodeObject(forKey: "numberOfLines") as? Int {
            self.numberOfLines = numberOfLines
        } else {
            self.numberOfLines = 1
        }
        
        if let highlightedTextColor = decoder.decodeObject(forKey: "highlightedTextColor") as? NSColor {
            self.highlightedTextColor = highlightedTextColor
        }
        
        self.isHighlighted = decoder.decodeObject(forKey: "isHighlighted") as! Bool
        
        if let shadowColor = decoder.decodeObject(forKey: "shadowColor") as? NSColor {
            self.shadowColor = shadowColor
        }
        
        self.shadowOffset = decoder.decodeObject(forKey: "shadowOffset") as! CGSize
        self.preferredMaxLayoutWidth = decoder.decodeObject(forKey: "preferredMaxLayoutWidth") as! CGFloat
        
        super.init(coder: decoder)
    }
    
    override open func encode(with aCoder: NSCoder) {
        if let text = self.text {
            aCoder.encode(text, forKey: "text")
        }
        
        if let attributedText = self.attributedText {
            aCoder.encode(attributedText, forKey: "attributedText")
        }
        
        aCoder.encode(font, forKey: "font")
        aCoder.encode(textColor, forKey: "textColor")
        aCoder.encode(backgroundColor, forKey: "backgroundColor")
        aCoder.encode(textAlignment, forKey: "textAlignment")
        aCoder.encode(lineBreakMode, forKey: "lineBreakMode")
        aCoder.encode(adjustsFontSizeToFitWidth, forKey: "adjustsFontSizeToFitWidth")
        aCoder.encode(minimumScaleFactor, forKey: "minimumScaleFactor")
        aCoder.encode(numberOfLines, forKey: "numberOfLines")
        
        if let highlightedTextColor = self.highlightedTextColor {
            aCoder.encode(highlightedTextColor, forKey: "highlightedTextColor")
        }
        
        aCoder.encode(isHighlighted, forKey: "isHighlighted")
        
        if let shadowColor = self.shadowColor {
            aCoder.encode(shadowColor, forKey: "shadowColor")
        }
        
        aCoder.encode(shadowOffset, forKey: "shadowOffset")
        aCoder.encode(preferredMaxLayoutWidth, forKey: "preferredMaxLayoutWidth")
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        drawingRect = setDrawingRect()
        
        let drawRect = NSRect(origin: drawingRect.origin, size: bounds.size)
        
        backgroundColor.setFill()
        
        dirtyRect.fill(using: NSCompositingOperation.destinationOver)
        
        if let text = text {
            text.draw(with: drawRect, options: drawingOptions(), attributes: attributes())
        } else if let attributedText = attributedText {
            attributedText.draw(with: drawRect, options: drawingOptions())
        }
    }
    
    override open func invalidateIntrinsicContentSize() {
        drawingRect = NSRect.zero
        super.invalidateIntrinsicContentSize()
    }
    
    private func setDrawingRect() -> NSRect {
        if NSIsEmptyRect(drawingRect) {
            let size = NSMakeSize(preferredMaxLayoutWidth, 0)
            
            if let text = text {
                drawingRect = text.boundingRect(with: size, options: drawingOptions(), attributes: attributes())
            } else if let attributedText = attributedText {
                drawingRect = attributedText.boundingRect(with: size, options: drawingOptions())
            }
            
            drawingRect.origin.x = ceil(drawingRect.origin.x)
            drawingRect.origin.y = ceil(drawingRect.origin.y)
            
            drawingRect.size.width = ceil(drawingRect.size.width)
            drawingRect.size.height = ceil(drawingRect.size.height)
        }
        
        return drawingRect
    }
    
    private func attributes() -> [NSAttributedString.Key : Any] {
        let shadow = NSShadow()
        
        var backgroundColor = self.backgroundColor
        
        if isHighlighted {
            if let highlightedTextColor = highlightedTextColor {
                backgroundColor = highlightedTextColor
            }
        }
        
        if let shadowColor = shadowColor {
            shadow.shadowColor = shadowColor
        }
        
        shadow.shadowOffset = shadowOffset
        
        return [
            NSAttributedString.Key.font: self.font,
            NSAttributedString.Key.foregroundColor: self.textColor,
            NSAttributedString.Key.backgroundColor: backgroundColor,
            NSAttributedString.Key.paragraphStyle: self.drawingParagraphStyle(),
            NSAttributedString.Key.shadow: shadow
        ]
    }
    
    private func drawingOptions() -> NSString.DrawingOptions {
        var options: NSString.DrawingOptions = .usesFontLeading
        
        if numberOfLines != 0 {
            options.insert(.usesLineFragmentOrigin)
        }
        
        return options
    }
    
    private func drawingParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = self.textAlignment
        
        if self.numberOfLines > 1 {
            paragraphStyle.lineBreakMode = self.lineBreakMode
        }
        
        return paragraphStyle
    }
}

#endif
