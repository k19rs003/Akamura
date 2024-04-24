//
//  SceneDelegate.swift
//  PBL_abe
//
//  Created by Abe on R 3/09/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        resetAppBadgeNumber()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        resetAppBadgeNumber()
    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        resetAppBadgeNumber()
    }

    // プッシュ通知のバッジ削除
    private func resetAppBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
