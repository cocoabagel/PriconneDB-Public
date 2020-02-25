//
//  UIWindow+Visible.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2020/02/25.
//  Copyright © 2020 Kazutoshi Baba. All rights reserved.
//

import UIKit

public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: self.rootViewController)
    }
    
    static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController)
            
        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController)
            
        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController)
            
        default:
            return viewController
        }
    }
}
