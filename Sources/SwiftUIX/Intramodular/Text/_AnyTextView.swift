//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import Combine
import Swift
import SwiftUI

public struct _AnyTextView {
    
}

@_documentation(visibility: internal)
extension _AnyTextView {
    public protocol _CustomAppKitOrUIKitClassProvider {
        func provideClass<Label: View>(
            labelType: Label.Type
        ) -> AppKitOrUIKitTextView.Type
    }
    
    struct _ConstantCustomAppKitOrUIKitClassProvider: _CustomAppKitOrUIKitClassProvider {
        let `class`: AppKitOrUIKitTextView.Type
        
        func provideClass<Label: View>(
            labelType: Label.Type
        ) -> AppKitOrUIKitTextView.Type {
            `class`
        }
    }
}

extension _AnyTextView {
    public struct _CustomAppKitOrUIKitClassConfiguration {
        public typealias UpdateOperation<T> = (_ view: T, _ context: any _AppKitOrUIKitViewRepresentableContext) -> Void
        
        let classProvider: any _AnyTextView._CustomAppKitOrUIKitClassProvider
        let update: UpdateOperation<AppKitOrUIKitTextView>
        
        init(
            classProvider: any _AnyTextView._CustomAppKitOrUIKitClassProvider,
            update: @escaping UpdateOperation<AppKitOrUIKitTextView>
        ) {
            self.classProvider = classProvider
            self.update = update
        }
        
        init(
            `class`: AppKitOrUIKitTextView.Type
        ) {
            self.init(
                classProvider: _AnyTextView._ConstantCustomAppKitOrUIKitClassProvider(class: `class`),
                update: { _, _ in }
            )
        }
        
        init<T: AppKitOrUIKitTextView>(
            `class`: T.Type,
            update: @escaping UpdateOperation<T> = { _, _ in }
        ) {
            self.init(
                classProvider: _AnyTextView._ConstantCustomAppKitOrUIKitClassProvider(class: `class`),
                update: { view, context in
                    guard let view = view as? T else {
                        assertionFailure()
                        
                        return
                    }
                    
                    update(view, context)
                }
            )
        }
    }
}

#endif
