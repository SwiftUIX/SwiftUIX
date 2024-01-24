//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct _AddTopOrBottomBar<BarContent: View>: ViewModifier {
    @Environment(\.userInterfaceIdiom) var userInterfaceIdiom
    
    enum Placement {
        case top
        case bottom
    }
    
    let barContent: BarContent
    let placement: Placement
    let separatorVisibility: Visibility
    
    func body(content: Content) -> some View {
        if userInterfaceIdiom == .mac && !userInterfaceIdiom._isMacCatalyst {
            VStack(spacing: 0) {
                if placement == .top {
                    separator
                }
                
                content
                
                if placement == .bottom {
                    separator
                }
            }
            .safeAreaInset(edge: placement == .top ? .top : .bottom) {
                barContent
            }
        } else {
            if userInterfaceIdiom._isMacCatalyst {
                VStack(spacing: 0) {
                    if placement == .top {
                        barContent
                        separator
                    }

                    content
                    
                    if placement == .bottom {
                        separator
                        barContent
                    }
                }
            } else {
                content
                    .safeAreaInset(edge: placement == .top ? .top : .bottom) {
                        VStack(spacing: 0) {
                            if placement == .bottom {
                                separator
                            }
                            
                            barContent
                            
                            if placement == .top {
                                separator
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private var separator: some View {
        if separatorVisibility != .hidden {
            Divider()
        }
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {
    @ViewBuilder
    public func _topBar<Content: View>(
        separator separatorVisibility: Visibility = .automatic,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            _AddTopOrBottomBar(
                barContent: content(),
                placement: .top,
                separatorVisibility: separatorVisibility
            )
        )
    }
    
    @ViewBuilder
    public func _bottomBar<Content: View>(
        separator separatorVisibility: Visibility = .automatic,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            _AddTopOrBottomBar(
                barContent: content(),
                placement: .bottom,
                separatorVisibility: separatorVisibility
            )
        )
    }
}
#else
extension View {
    @ViewBuilder
    public func _bottomBar<Content: View>(
        separator separatorVisibility: Visibility = .automatic,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            _AddTopOrBottomBar(
                barContent: content(),
                placement: .bottom,
                separatorVisibility: separatorVisibility
            )
        )
        /*let content = content()
        
        IntrinsicSizeReader { size in
            self.toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    content
                        .frame(maxWidth: 512)
                }
            }
        }*/
    }
}
#endif
