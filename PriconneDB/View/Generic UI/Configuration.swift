//
//  Configuration.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

public struct Constants {
    
    public static var tagSize: CGSize {
        let w = UIScreen.main.bounds.width
        switch w {
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
