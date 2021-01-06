//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

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
