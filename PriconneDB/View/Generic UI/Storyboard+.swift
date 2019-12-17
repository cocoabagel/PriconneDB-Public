//
//  Storyboard+.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func storyboard(_ storyboardName: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboardName.rawValue, bundle: Bundle(for: AppDelegate.self))
    }
    
    func instantiateViewController<T>(ofType type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
}
