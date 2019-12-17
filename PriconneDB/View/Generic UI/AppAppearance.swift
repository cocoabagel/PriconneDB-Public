//
//  AppAppearance.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/04.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

func applyAppAppearance() {
    styleWindow()
}

private func styleWindow() {
    guard let window = UIApplication.shared.delegate?.window else { return }
    if window?.traitCollection.userInterfaceStyle == .dark {
        window?.backgroundColor = UIColor.black
    } else {
        window?.backgroundColor = UIColor.white
    }
    window?.tintColor = UIColor(hex: "FE8697")
}
