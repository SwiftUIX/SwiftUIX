//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct KeyboardAvoidingViewController<Content: View>: UIViewControllerRepresentable {
    class _UIHostingController: UIHostingController<Content> {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            view.backgroundColor = .clear
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillChangeFrame),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        }
        
        @objc private func keyboardWillChangeFrame(_ notification: Notification) {
            guard
                isViewLoaded,
                let window = view.window,
                let userInfo = notification.userInfo,
                let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
                let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else {
                    return
            }
            
            let endFrameInWindow = window.convert(endFrame, from: nil)
            let endFrameInView = view.convert(endFrameInWindow, from: nil)
            let endFrameIntersection = view.bounds.intersection(endFrameInView)
            let keyboardHeight = view.bounds.maxY - endFrameIntersection.minY
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve << 16), animations: {
                self.additionalSafeAreaInsets.bottom = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
    public typealias UIViewControllerType = _UIHostingController
    
    var rootView: Content
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(rootView: rootView)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootView = rootView
    }
}

extension View {
    public func keyboardAvoiding() -> some View {
        KeyboardAvoidingViewController(rootView: self)
    }
}

#endif
