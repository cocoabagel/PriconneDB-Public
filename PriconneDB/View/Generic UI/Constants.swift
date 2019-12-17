//
//  Configuration.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

public struct Constants {
    
    public static var teamUnitTagSize: CGSize {
        guard let visibleVC = UIApplication.shared.keyWindow?.visibleViewController else {
             return CGSize(width: 64, height: 64)
        }
        let w = visibleVC.view.bounds.width
        switch w {
        case ...300:
            return CGSize(width: 44, height: 44)
        case 320:
            return CGSize(width: 53, height: 53)
        case 375:
            return CGSize(width: 64, height: 64)
        case 414...:
            return CGSize(width: 72, height: 72)
        default:
            return CGSize(width: 64, height: 64)
        }
    }
    
    public static var unitTagSize: CGSize {
        guard let visibleVC = UIApplication.shared.keyWindow?.visibleViewController else {
            return CGSize(width: 64, height: 64)
        }
        switch visibleVC.view.bounds.width {
        case ...300:
            return CGSize(width: 44, height: 44)
        case 320:
            return CGSize(width: 53, height: 53)
        case 375:
            return CGSize(width: 64, height: 64)
        case 414...:
            return CGSize(width: 72, height: 72)
        default:
            return CGSize(width: 64, height: 64)
        }
    }
}

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
