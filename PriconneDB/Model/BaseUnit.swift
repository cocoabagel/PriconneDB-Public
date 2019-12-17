//
//  Chara.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/03/16.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift
import Realm

public class Unit: Object {
    
    @objc public dynamic var key: String = ""
    @objc public dynamic var name: String = ""
    @objc public dynamic var position: Int = 0
    @objc public dynamic var starRank: Int = 0
    @objc public dynamic var uniqueEquipment: Bool = false
    @objc public dynamic var iconURL: String = ""
    @objc public dynamic var lastUpdated: Date = Date()
    
    override public static func primaryKey() -> String? {
        return "key"
    }
    
    override public static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    public convenience init(name: String, position: Int, starRank: Int, uniqueEquipment: Bool, iconURL: String, key: String = "") {
        self.init()
        self.key = key
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.iconURL = iconURL
        self.lastUpdated = Date()
    }
    
    public convenience init?(document: QueryDocumentSnapshot) {
        self.init()
        guard
            let name = document.data()["name"] as? String,
            let position = document.data()["position"] as? Int,
            let starRank = document.data()["starRank"] as? Int,
            let uniqueEquipment = document.data()["uniqueEquipment"] as? Bool,
            let iconURL = document.data()["iconURL"] as? String,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }
        self.key = document.reference.documentID
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.iconURL = iconURL
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public convenience init?(dict: [String: Any]) {
        self.init()
        guard
            let name = dict["name"] as? String,
            let position = dict["position"] as? Int,
            let starRank = dict["starRank"] as? Int,
            let uniqueEquipment = dict["uniqueEquipment"] as? Bool,
            let iconURL = dict["iconURL"] as? String,
            let lastUpdated = dict["lastUpdated"] as? Timestamp else { return nil }
        self.key = ""
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.iconURL = iconURL
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public func toAnyObject() -> [String: Any] {
        return [
            "name": name,
            "position": position,
            "starRank": starRank,
            "uniqueEquipment": uniqueEquipment,
            "iconURL": iconURL,
            "lastUpdated": Timestamp(date: lastUpdated)
        ]
    }
}
