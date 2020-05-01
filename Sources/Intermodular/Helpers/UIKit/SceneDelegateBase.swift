//
// Copyright (c) Vatsal Manot
//

#if os(iOS)

import Foundation
import UIKit

open class SceneDelegateBase<AppDelegate: UIApplicationDelegate>: UIResponder, UIWindowSceneDelegate {
    open var window: UIWindow?
    
    open func makeRootViewController() -> UIViewController {
        .init()
    }
    
    @available(iOSApplicationExtension, unavailable)
    open var applicationDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
    
    open func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    open func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    open func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    open func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    open func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}

#endif
