//
//  Logger.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/04/30.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

struct Logger {
    static func setup() {
        #if DEBUG
        configureDebugLogging()
        #else
        configureReleaseLogging()
        #endif
    }
}

private extension Logger {
    static func configureDebugLogging() {
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss$d $L $M"
        console.minLevel = .debug
        console.levelString.verbose = "🐷"
        console.levelString.debug = "🛠️"
        console.levelString.info = "ℹ️"
        console.levelString.warning = "⚠️"
        console.levelString.error = "💥"
        log.addDestination(console)
    }
    
    static func configureReleaseLogging() {
        let console = ConsoleDestination()
        // Log to Apple System Log
        console.useNSLog = false
        console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $M"
        console.minLevel = .error
        log.addDestination(console)
    }
}
