//
//  ControlFlowContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct ControlFlowContentView: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("Control Flow")
            }
        }
        .navigationBarTitle("Control Flow")
    }

}

#if DEBUG
struct ControlFlowContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ControlFlowContentView()
        }
    }
}
#endif
