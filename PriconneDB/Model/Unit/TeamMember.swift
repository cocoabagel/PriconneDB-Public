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

public class TeamMember: Object {
    
    @objc public dynamic var name: String = ""
    @objc public dynamic var position: Int = 0
    @objc public dynamic var starRank: Int = 0
    @objc public dynamic var uniqueEquipment: Bool = false
    @objc public dynamic var star3IconURL: String = ""
    @objc public dynamic var star6IconURL: String = ""
    @objc public dynamic var lastUpdated: Date = Date()
    @objc public dynamic var iconURL: String {
        guard !star6IconURL.isEmpty else { return star3IconURL }
        return starRank > 5 ? star6IconURL : star3IconURL
    }
    
    override public static func indexedProperties() -> [String] {
        return ["position", "name"]
    }
    
    public convenience init(name: String, position: Int, starRank: Int, uniqueEquipment: Bool, star3IconURL: String, star6IconURL: String = "") {
        self.init()
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        self.star6IconURL = star6IconURL
        self.lastUpdated = Date()
    }
    
    public convenience init?(dict: [String: Any]) {
        self.init()
        guard
            let name = dict["name"] as? String,
            let position = dict["position"] as? Int,
            let starRank = dict["starRank"] as? Int,
            let uniqueEquipment = dict["uniqueEquipment"] as? Bool,
            let star3IconURL = dict["iconURL"] as? String,
            let lastUpdated = dict["lastUpdated"] as? Timestamp else { return nil }
        let star6IconURL: String
        if let iconURL = dict["star6IconURL"] as? String {
            star6IconURL = iconURL
        } else {
            star6IconURL = ""
        }
        
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        self.star6IconURL = star6IconURL
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public func toAnyObject() -> [String: Any] {
        return [
            "name": name,
            "position": position,
            "starRank": starRank,
            "uniqueEquipment": uniqueEquipment,
            "iconURL": star3IconURL,
            "star3IconURL": star3IconURL,
            "star6IconURL": star6IconURL,
            "lastUpdated": Timestamp(date: lastUpdated)
        ]
    }
}
