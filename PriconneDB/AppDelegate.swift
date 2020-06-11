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
import FirebaseInstanceID

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
        
        // ここ必要
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        // デフォルト値設定、初回のみ有効
//        remoteConfig.setDefaults(["test3": NSString(string: "hogehhoge")])
        // キャッシュされている
        log.debug(remoteConfig["ab_test_enabled"].stringValue)

        func fetchConfig() {
          let expirationDuration = 0
          remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                log.debug("Config fetched!")
                self.remoteConfig.activate(completionHandler: nil)
                log.debug(self.remoteConfig["ab_test_enabled"].stringValue)
            } else {
                log.error("Config not fetched")
                log.error("Error: \(error?.localizedDescription ?? "No error available.")")
            }
          }
        }
        fetchConfig()
         
        if let enabled = remoteConfig["ab_test_enabled"].stringValue {
            switch enabled {
            case "a_key":
                log.info("a_key get")
            case "b_key":
                log.info("b_key get")
            default:
                log.info("none")
            }
        }
        
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error{
                log.error("Error fetching remote instange ID(Token): \(error)")
            }else if let result = result{
                log.info("Remote instance ID token: \(result.token)")
            }
        })
        
        return true
    }

}
