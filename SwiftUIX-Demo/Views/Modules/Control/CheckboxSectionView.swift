//
//  CheckboxSectionView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI
import SwiftUIX

struct CheckboxSectionView: View {

    @State var check1on: Bool = false
    @State var check2on: Bool = false
    @State var check3on: Bool = true

    @ViewBuilder
    var body: some View {
        Text("CheckBox")
            .font(.title)

        Checkbox(isOn: $check1on) {
            Text("Check 1 (off by default)")
        }

        Checkbox(isOn: $check2on) {
            Text("Check 2 (off by default)")
        }

        Checkbox(isOn: $check3on) {
            Text("Check 3 (on by default)")
        }
    }

}
