//
//  ContentView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    RowView(destination: EmptyView()) {
                        Text("Control")
                    }

                    RowView(destination: EmptyView()) {
                        Text("Control Flow")
                    }

                    RowView(destination: EmptyView()) {
                        Text("Data")
                    }

                    RowView(destination: EmptyView()) {
                        Text("Presentation")
                    }

                    RowView(destination: EmptyView()) {
                        Text("Text")
                    }
                }
                .padding()
            }
            .navigationBarTitle("SwiftUIX Demo")
        }
    }
}

struct RowView<Destination: View, Content: View>: View {

    let destination: Destination
    let content: () -> Content

    var body: some View {
        NavigationLink(destination: self.destination) {
            HStack {
                self.content()
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
        }
        .background(RowBackgroundView())
        .shadow(radius: 3)
    }

}

struct RowBackgroundView: View {

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.blue)
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
