//
//  SceneDelegate.swift
//  UnsplashExplorer
//
//  Created by sunghyun_kim on 2022/03/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let tabBarController = MainTabBarController()
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

