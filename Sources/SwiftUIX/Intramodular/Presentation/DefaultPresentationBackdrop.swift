//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct DefaultPresentationBackdrop: View {
    @Environment(\.presentationManager) var presentationManager
    @Environment(\._presentationTransitionPhase) var transitionPhase
    
    @State var viewDidAppear = false
    
    var opacity: Double {
        guard let transitionPhase = transitionPhase else {
            return 0.0
        }
        
        switch transitionPhase {
            case .willDismiss:
                return 0.0
            case .didDismiss:
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
