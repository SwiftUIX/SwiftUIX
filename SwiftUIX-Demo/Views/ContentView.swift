//
//  ContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct ContentView: View {

    let listItems: [ListViewItem] = [
        ListViewItem(title: "Control", destination: AnyView(ControlContentView())),
        ListViewItem(title: "Control Flow", destination: AnyView(ControlFlowContentView())),
        ListViewItem(title: "Data", destination: AnyView(DataContentView())),
        ListViewItem(title: "Presentation", destination: AnyView(PresentationContentView())),
        ListViewItem(title: "Text", destination: AnyView(TextContentView()))
    ]

    var body: some View {
        NavigationView {
            ListView(items: self.listItems)
            .navigationBarTitle("SwiftUIX Demo")
        }
    }

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
