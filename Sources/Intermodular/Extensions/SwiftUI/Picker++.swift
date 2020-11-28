//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Picker where Label == Text, SelectionValue: CaseIterable & CustomStringConvertible & Hashable, SelectionValue.AllCases: RandomAccessCollection {
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>
    ) where Content == AnyView {
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
