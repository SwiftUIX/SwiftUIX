//
//  ControlContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct ControlContentView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CheckboxSectionView()

                Divider()
            }
            .padding()
        }
        .navigationBarTitle("Control")
    }

}

#if DEBUG
struct ControlContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ControlContentView()
        }
    }
}
#endif
