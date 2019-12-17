//
//  DateFormatting.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/11/12.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation

public let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    dateFormatter.locale = Locale(identifier: "ja_JP")
    return dateFormatter
}()
