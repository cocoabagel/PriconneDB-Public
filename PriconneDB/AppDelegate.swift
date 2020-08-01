//
//  AppDelegate.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/03/10.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import KingfisherWebP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remoteConfig: RemoteConfig!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Logger.setup()
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
        applyAppAppearance()

        return true
    }

}
