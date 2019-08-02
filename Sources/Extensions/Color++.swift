//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if canImport(UIKit)

extension Color {
    /* Some colors that are used by system elements and applications.
     * These return named colors whose values may vary between different contexts and releases.
     * Do not make assumptions about the color spaces or actual colors used.
     */
    public static var systemRed: Color {
        return .init(.systemRed)
    }

    public static var systemGreen: Color {
        return .init(.systemGreen)
    }

    public static var systemBlue: Color {
        return .init(.systemBlue)
    }

    public static var systemOrange: Color {
        return .init(.systemOrange)
    }

    public static var systemYellow: Color {
        return .init(.systemYellow)
    }

    public static var systemPink: Color {
        return .init(.systemPink)
    }

    public static var systemPurple: Color {
        return .init(.systemPurple)
    }

    public static var systemTeal: Color {
        return .init(.systemTeal)
    }

    public static var systemIndigo: Color {
        return .init(.systemIndigo)
    }


    /* Foreground colors for static text and related elements.
     */
    public static var label: Color {
        return .init(.label)
    }

    public static var secondaryLabel: Color {
        return .init(.secondaryLabel)
    }

    public static var tertiaryLabel: Color {
        return .init(.tertiaryLabel)
    }

    public static var quaternaryLabel: Color {
        return .init(.quaternaryLabel)
    }


    /* Foreground color for standard system links.
     */
    public static var link: Color {
        return .init(.link)
    }


    /* Foreground color for placeholder text in controls or text fields or text views.
     */
    public static var placeholderText: Color {
        return .init(.placeholderText)
    }


    /* Foreground colors for separators (thin border or divider lines).
     * `separatorColor` may be partially transparent, so it can go on top of any content.
     * `opaqueSeparatorColor` is intended to look similar, but is guaranteed to be opaque, so it will
     * completely cover anything behind it. Depending on the situation, you may need one or the other.
     */
    public static var separator: Color {
        return .init(.separator)
    }

    public static var opaqueSeparator: Color {
        return .init(.opaqueSeparator)
    }


    /* We provide two design systems (also known as "stacks") for structuring an iOS app's backgrounds.
     *
     * Each stack has three "levels" of background colors. The first color is intended to be the
     * main background, farthest back. Secondary and tertiary colors are layered on top
     * of the main background, when appropriate.
     *
     * Inside of a discrete piece of UI, choose a stack, then use colors from that stack.
     * We do not recommend mixing and matching background colors between stacks.
     * The foreground colors above are designed to work in both stacks.
     *
     * 1. systemBackground
     *    Use this stack for views with standard table views, and designs which have a white
     *    primary background in light mode.
     */
    public static var systemBackground: Color {
        return .init(.systemBackground)
    }

    public static var secondarySystemBackground: Color {
        return .init(.secondarySystemBackground)
    }

    public static var tertiarySystemBackground: Color {
        return .init(.tertiarySystemBackground)
    }


    /* 2. systemGroupedBackground
     *    Use this stack for views with grouped content, such as grouped tables and
     *    platter-based designs. These are like grouped table views, but you may use these
     *    colors in places where a table view wouldn't make sense.
     */
    public static var systemGroupedBackground: Color {
        return .init(.systemBackground)
    }

    public static var secondarySystemGroupedBackground: Color {
        return .init(.systemBackground)
    }

    public static var tertiarySystemGroupedBackground: Color {
        return .init(.tertiarySystemGroupedBackground)
    }


    /* Fill colors for UI elements.
     * These are meant to be used over the background colors, since their alpha component is less than 1.
     *
     * systemFillColor is appropriate for filling thin and small shapes.
     * Example: The track of a slider.
     */
    public static var systemFill: Color {
        return .init(.systemFill)
    }


    /* secondarySystemFillColor is appropriate for filling medium-size shapes.
     * Example: The background of a switch.
     */
    public static var secondarySystemFill: Color {
        return .init(.secondarySystemFill)
    }


    /* tertiarySystemFillColor is appropriate for filling large shapes.
     * Examples: Input fields, search bars, buttons.
     */
    public static var tertiarySystemFill: Color {
        return .init(.tertiarySystemFill)
    }


    /* quaternarySystemFillColor is appropriate for filling large areas containing complex content.
     * Example: Expanded table cells.
     */
    public static var quaternarySystemFill: Color {
        return .init(.quaternarySystemFill)
    }
}

#endif
