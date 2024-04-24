//
//  UINavigation.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/11/13.
//

import UIKit

class UINavigation: UINavigationController {
    
    // 画面の回転設定　表示しているViewControllerに従う
    open override var shouldAutorotate: Bool {
        guard let viewController = self.visibleViewController else {
            return false
        }
        return viewController.shouldAutorotate
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let viewController = self.visibleViewController else {
            return .allButUpsideDown
        }
        return viewController.supportedInterfaceOrientations
    }
}
