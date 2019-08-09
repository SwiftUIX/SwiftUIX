//
//  TextContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct TextContentView: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("Text")
            }
        }
        .navigationBarTitle("Text")
    }

}

#if DEBUG
struct TextContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TextContentView()
        }
    }
}
#endif
