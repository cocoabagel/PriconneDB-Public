//
//  LocalStore.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/02.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation

struct LocalStore {
    private static let userDefaults = UserDefaults.standard
    private static let selectUnitNamesKey = "selectUnitNamesKey"
}

extension LocalStore {
    static func setSelectUnitNames(_ names: [String]) {
        userDefaults.set(names, forKey: selectUnitNamesKey)
    }
    
    static func deleteSelectUnitNames() {
        userDefaults.removeObject(forKey: selectUnitNamesKey)
        userDefaults.synchronize()
    }
    
    static func selectUnitNames() -> [String] {
        return userDefaults.array(forKey: selectUnitNamesKey) as? [String] ?? []
    }
}
