//
//  UIButton+.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/10/29.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

extension UIButton {
    
    @IBInspectable private var highlightedColor: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            let image = UIImage(color: color, size: CGSize(width: self.frame.size.width * 2, height: self.frame.size.height * 2))
            self.setBackgroundImage(image, for: .highlighted)
        }
    }
    
    @IBInspectable private var normalColor: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            let image = UIImage(color: color, size: CGSize(width: self.frame.size.width * 2, height: self.frame.size.height * 2))
            self.setBackgroundImage(image, for: .normal)
        }
    }
    
    @IBInspectable private var inactiveColor: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            let image = UIImage(color: color, size: CGSize(width: self.frame.size.width * 2, height: self.frame.size.height * 2))
            self.setBackgroundImage(image, for: .disabled)
        }
    }
    
}

public extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
