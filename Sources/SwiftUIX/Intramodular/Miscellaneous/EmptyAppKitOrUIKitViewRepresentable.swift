//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct EmptyAppKitOrUIKitViewRepresentable: View {
    private let update: (any _AppKitOrUIKitViewRepresentableContext) -> Void
    private let dismantle: () -> Void
    
    public init(
        update: @escaping (any _AppKitOrUIKitViewRepresentableContext) -> Void,
        dismantle: @escaping () -> Void = { }
    ) {
        self.update = update
        self.dismantle = dismantle
    }
    
    public var body: some View {
        Guts(update: update, dismantle: dismantle)
            .frame(width: 0, height: 0)
            .opacity(0)
            .accessibility(hidden: true)
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
extension EmptyAppKitOrUIKitViewRepresentable {
    private struct Guts: AppKitOrUIKitViewRepresentable {
        public typealias AppKitOrUIKitViewType = AppKitOrUIKitView
        
        private let update: (any _AppKitOrUIKitViewRepresentableContext) -> Void
        private let dismantle: () -> Void
        
        init(
            update: @escaping (any _AppKitOrUIKitViewRepresentableContext) -> Void,
            dismantle: @escaping () -> Void = { }
        ) {
            self.update = update
            self.dismantle = dismantle
        }
        
        public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
            AppKitOrUIKitViewType()
        }
        
        public func updateAppKitOrUIKitView(
            _ view: AppKitOrUIKitViewType,
            context: Context
        ) {
            DispatchQueue.main.async {
                update(context)
            }
        }
        
        /*public static func dismantleAppKitOrUIKitView(
         _ view: Self,
         coordinator: Coordinator
         ) {
         DispatchQueue.main.async {
         view.dismantle()
         }
         }*/
    }
}
#elseif os(watchOS)
extension EmptyAppKitOrUIKitViewRepresentable {
    private struct Guts: View {
        private let update: (any _AppKitOrUIKitViewRepresentableContext) -> Void
        private let dismantle: () -> Void
        
        init(
            update: @escaping (any _AppKitOrUIKitViewRepresentableContext) -> Void,
            dismantle: @escaping () -> Void = { }
        ) {
            self.update = update
            self.dismantle = dismantle
        }
        
        public var body: some View {
            ZeroSizeView() // FIXME
        }
    }
}
#endif
