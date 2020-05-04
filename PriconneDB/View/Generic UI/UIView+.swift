//
//  UIView+.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/28.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    @IBInspectable private var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    @IBInspectable private var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable private var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}
