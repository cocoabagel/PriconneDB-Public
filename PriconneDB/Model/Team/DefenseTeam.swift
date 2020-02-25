//
//  BaseTeam.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/01.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Realm
import RealmSwift

// RealmとFirebase共通のモデル
public enum AttackType: String {
    case defend
    case attack
    
    static let all = [
        defend,
        attack
    ]
}

public class DefenseTeam: Object {
    @objc public dynamic var key: String = ""
    public var attackType: AttackType {
        get { return AttackType(rawValue: rawAttackType)! }
        set { rawAttackType = newValue.rawValue }
    }
    @objc public dynamic var rawAttackType: String = AttackType.defend.rawValue
    public let members: List<TeamMember> = List<TeamMember>()
    public let wins: List<AttackTeam> = List<AttackTeam>()
    @objc public dynamic var uid: String = ""
    @objc public dynamic var created: Date = Date()
    @objc public dynamic var lastUpdated: Date = Date()
    
    override public static func primaryKey() -> String? {
        return "key"
    }
    
    override public static func indexedProperties() -> [String] {
        return ["lastUpdated"]
    }
    
    public convenience init(members: [TeamMember], wins: [AttackTeam] = [], uid: String = "", key: String = "") {
        self.init()
        self.key = key
        self.attackType = .defend
        self.members.append(objectsIn: members)
        self.wins.append(objectsIn: wins)
        self.uid = uid
        self.created = Date()
        self.lastUpdated = Date()
    }
    
    public convenience init?(document: QueryDocumentSnapshot) {
        self.init()
        guard
            let attackTypeString = document.data()["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = document.data()["members"] as? [[String: Any]],
            let wins = document.data()["wins"] as? [[String: Any]],
            let uid = (document.data()["uid"] ?? "") as? String,
            let created = document.data()["created"] as? Timestamp,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }

        self.key = document.reference.documentID
        self.attackType = attackType
        self.members.append(objectsIn: members.compactMap(TeamMember.init))
        self.wins.append(objectsIn: wins.compactMap(AttackTeam.init))
        self.uid = uid
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public convenience init?(dict: [String: Any]) {
        self.init()
        guard
            let attackTypeString = dict["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = dict["members"] as? [[String: Any]],
            let wins = dict["wins"] as? [[String: Any]],
            let uid = (dict["uid"] ?? "") as? String,
            let created = dict["created"] as? Timestamp,
            let lastUpdated = dict["lastUpdated"] as? Timestamp else { return nil }

        self.key = ""
        self.attackType = attackType
        self.members.append(objectsIn: members.compactMap(TeamMember.init))
        self.wins.append(objectsIn: wins.compactMap(AttackTeam.init))
        self.uid = uid
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public func toAnyObject() -> [String: Any] {
        return [
            "attackType": attackType.rawValue,
            "members": Array(members).map({ $0.toAnyObject() }),
            "wins": Array(wins).map({ $0.toAnyObject() }),
            "uid": uid,
            "created": Timestamp(date: created),
            "lastUpdated": Timestamp(date: lastUpdated)
        ]
    }
}
