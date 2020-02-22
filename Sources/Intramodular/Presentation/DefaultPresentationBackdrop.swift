//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct DefaultPresentationBackdrop: View {
    @Environment(\.presentationManager) var presentationManager
    @Environment(\.presentationTransitionType) var presentationTransitionType
    
    @State var viewDidAppear = false
    
    var opacity: Double {
        guard let presentationTransitionType = presentationTransitionType else {
            return 0.0
        }
        
        switch presentationTransitionType {
            case .dismissalWillBegin:
                return 0.0
            case .dismissalDidEnd:
                return 0.0
            default:
                break
        }
        
        if viewDidAppear {
            return 0.3
        } else {
            return 0.0
        }
    }
    
    public var body: some View {
        #if os(tvOS)
        return Color.black
            .opacity(opacity)
            .onAppear { self.viewDidAppear = true }
            .animation(.default)
        #else
        return Color.black
            .opacity(opacity)
            .edgesIgnoringSafeArea(.all)
            .onAppear { self.viewDidAppear = true }
            .animation(.default)
            .onTapGesture(perform: dismiss)
        #endif
    }
    
    func dismiss() {
        presentationManager.dismiss()
    }
}
