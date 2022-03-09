//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Picker {
    #if canImport(GroupActivities)
    public init<Data: RandomAccessCollection, ID: Hashable, RowContent: View>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        selection: Binding<Data.Element>,
        @ViewBuilder content: @escaping (Data.Element) -> RowContent
    ) where Data.Element == SelectionValue, Label == EmptyView, Content == ForEach<Data, ID, RowContent> {
        self.init(selection: selection) {
            ForEach(data, id: id) {
                content($0)
            }
        } label: {
            EmptyView()
        }
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable, RowContent: View, Placeholder: View>(
        _ data: Data,
        id: KeyPath<Optional<Data.Element>, ID>,
        selection: Binding<Data.Element?>,
        @ViewBuilder content: @escaping (Data.Element) -> RowContent,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) where Label == EmptyView, SelectionValue == Optional<Data.Element>, Content == ForEach<Array<Optional<Data.Element>>, ID, AnyView> {
        self.init(
            selection: Binding(
                get: { selection.wrappedValue },
                set: { selection.wrappedValue = ($0 == selection.wrappedValue) ? nil : $0 }
            )
        ) {
            ForEach(data.map({ Optional.some($0) }) + [nil], id: id) { element in
                PassthroughView {
                    if let element = element {
                        content(element)
                    } else {
                        placeholder()
                    }
                }
                .tag(element)
                .eraseToAnyView()
            }
        } label: {
            EmptyView()
        }
    }
    #endif
}

extension Picker where Label == Text, SelectionValue: CaseIterable & CustomStringConvertible & Hashable, SelectionValue.AllCases: RandomAccessCollection, Content == AnyView {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>
    )  {
        self.init(titleKey, selection: selection) {
            ForEach(SelectionValue.allCases, id: \.self) { value in
                Text(value.description)
                    .tag(value)
            }
            .eraseToAnyView()
        }
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<SelectionValue>
    ) where Content == AnyView {
        self.init(title, selection: selection) {
            ForEach(SelectionValue.allCases, id: \.self) { value in
                Text(value.description)
                    .tag(value)
            }
            .eraseToAnyView()
        }
    }
}

extension Picker where Label == EmptyView, Content == AnyView {
    public init(
        selection: Binding<SelectionValue>
    ) where SelectionValue.AllCases: RandomAccessCollection, SelectionValue: CaseIterable & CustomStringConvertible & Hashable {
        self.init(selection: selection) {
            PassthroughView {
                ForEach(SelectionValue.allCases, id: \.self) { value in
                    Text(value.description)
                        .tag(Optional.some(value))
                }
            }
            .eraseToAnyView()
        } label: {
            EmptyView()
        }
    }
}

extension Picker where Label == Text, Content == AnyView {
    public init<T: CaseIterable & CustomStringConvertible & Hashable>(
        _ titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>
    ) where T.AllCases: RandomAccessCollection, SelectionValue == Optional<T> {
        self.init(titleKey, selection: selection) {
            PassthroughView {
                ForEach(T.allCases, id: \.self) { value in
                    Text(value.description)
                        .tag(Optional.some(value))
                }
            }
            .eraseToAnyView()
        }
    }
    
    public init<S: StringProtocol, T: CaseIterable & CustomStringConvertible & Hashable>(
        _ title: S,
        selection: Binding<SelectionValue>
    ) where T.AllCases: RandomAccessCollection, SelectionValue == Optional<T> {
        self.init(title, selection: selection) {
            PassthroughView {
                ForEach(T.allCases, id: \.self) { value in
                    Text(value.description)
                        .tag(Optional.some(value))
                }
            }
            .eraseToAnyView()
        }
    }
}

extension Picker where Label == Text, SelectionValue == Int, Content == AnyView {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>,
        in range: ClosedRange<SelectionValue>
    )  {
        self.init(titleKey, selection: selection) {
            ForEach(range, id: \.self) { value in
                Text(String(describing: value))
                    .tag(value)
            }
            .eraseToAnyView()
        }
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<SelectionValue>,
        in range: ClosedRange<SelectionValue>
    )  {
        self.init(title, selection: selection) {
            ForEach(range, id: \.self) { value in
                Text(String(describing: value))
                    .tag(value)
            }
            .eraseToAnyView()
        }
    }
}
