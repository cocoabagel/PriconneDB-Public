//
//  RemarksCell.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/11/12.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit

class RemarksCell: UITableViewCell {
    // MARK: - Properties
    static let placeholderText: String = "コメントです、タップして編集できます"
    
    // MARK: - View Elements
    @IBOutlet weak var remarksLabel: UILabel!
    
    func configureCell(_ text: String) {
        remarksLabel.text = text.isEmpty ? RemarksCell.placeholderText : text
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                remarksLabel.textColor = text.isEmpty ? UIColor.lightGray : UIColor.white
            } else {
                remarksLabel.textColor = text.isEmpty ? UIColor.lightGray : UIColor.black
            }
        } else {
            remarksLabel.textColor = text.isEmpty ? UIColor.lightGray: UIColor.black
        }
    }
}
