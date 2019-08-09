//
//  DataContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct DataContentView: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("Data")
            }
        }
        .navigationBarTitle("Data")
    }

}

#if DEBUG
struct DataContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataContentView()
        }
    }
}
#endif
