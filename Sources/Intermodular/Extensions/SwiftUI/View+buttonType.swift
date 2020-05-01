//
//  Created by Lorenzo Fiamingo on 01/05/2020.
//

import SwiftUI


public enum ButtonType: Int {
    
//    case custom = 0
//    case sysyem = 1
    case detailDisclosure = 2
    case infoLight = 3
    case infoDark = 4
    case contactAdd = 5
//    case plain = 6
    case close = 7
}


fileprivate struct ButtonOfType: UIViewRepresentable {
    
    let type: ButtonType
    
    func makeUIView(context: Context) -> UIButton {
        UIButton(type: UIButton.ButtonType(rawValue: type.rawValue)!)
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
    }
}

fileprivate struct ButtonOfTypeStyle: ButtonStyle {
    
    let type: ButtonType
 
    func makeBody(configuration: Self.Configuration) -> some View {
        ButtonOfType(type: type)
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets the style for `Button` within the environment of `self`.
    public func buttonType(_ type: ButtonType) -> some View {
        self.buttonStyle(ButtonOfTypeStyle(type: type))
    }
}
