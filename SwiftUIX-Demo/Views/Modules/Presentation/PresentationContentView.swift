//
//  PresentationContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct PresentationContentView: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("Presentation")
            }
        }
        .navigationBarTitle("Presentation")
    }

}

#if DEBUG
struct PresentationContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PresentationContentView()
        }
    }
}
#endif
