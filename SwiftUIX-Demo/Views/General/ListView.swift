//
//  ListView.swift
//  SwiftUIX-Demo
//
//  Created by Kevin Romero Peces-Barba on 8/9/19.
//

import SwiftUI
import Combine

struct ListViewItem: Identifiable {

    let title: String
    let destination: AnyView

    var id: String { return title }

}

struct ListView: View {

    let items: [ListViewItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(items) { RowView(item: $0) }
            }
            .padding()
        }
    }

}

struct RowView: View {

    let item: ListViewItem

    var body: some View {
        NavigationLink(destination: self.item.destination) {
            HStack {
                Text(self.item.title)
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
