//
//  StoryboardHelper.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main = "Main"
}

protocol StoryboardHelper {}

extension StoryboardHelper where Self: UIViewController {
    
    static func instantiate(storyboard: Storyboard) -> Self {
        let storyboard = UIStoryboard.storyboard(storyboard)
        return storyboard.instantiateViewController(ofType: Self.self)
    }
    
}

extension UIViewController: StoryboardHelper {}
