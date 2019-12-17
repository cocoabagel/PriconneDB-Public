//
//  Team.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/03/16.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Realm
import RealmSwift

public class AttackTeam: Object {
    public var attackType: AttackType {
        get { return AttackType(rawValue: rawAttackType)! }
        set { rawAttackType = newValue.rawValue }
    }
    @objc public dynamic var rawAttackType: String = AttackType.attack.rawValue
    public let members: List<TeamMember> = List<TeamMember>()
    @objc public dynamic var recommend: Bool = false
    @objc public dynamic var likeCount: Int = 0
    @objc public dynamic var dislikeCount: Int = 0
    @objc public dynamic var uid: String = ""
    @objc public dynamic var remarks: String = ""
    @objc public dynamic var created: Date = Date()
    @objc public dynamic var lastUpdated: Date = Date()
    
    override public static func indexedProperties() -> [String] {
        return ["lastUpdated"]
    }
    
    public convenience init(members: [TeamMember]) {
        self.init()
        self.attackType = .attack
        self.members.append(objectsIn: members)
        self.recommend = false
        self.likeCount = 0
        self.dislikeCount = 0
        self.uid = ""
        self.remarks = ""
        self.created = Date()
        self.lastUpdated = Date()
    }
    
    public convenience init?(document: QueryDocumentSnapshot) {
        self.init()
        guard
            let attackTypeString = document.data()["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = document.data()["members"] as? [[String: Any]],
            let recommend = (document.data()["recommend"] ?? false) as? Bool,
            let likeCount = (document.data()["likeCount"] ?? 0) as? Int,
            let dislikeCount = (document.data()["dislikeCount"] ?? 0) as? Int,
            let uid = (document.data()["uid"] ?? "") as? String,
            let remarks = (document.data()["remarks"] ?? "") as? String,
            let created = document.data()["created"] as? Timestamp,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }
        self.attackType = attackType
        self.members.append(objectsIn: members.compactMap(TeamMember.init))
        self.recommend = recommend
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.uid = uid
        self.remarks = remarks
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public convenience init?(dict: [String: Any]) {
        self.init()
        guard
            let attackTypeString = dict["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = dict["members"] as? [[String: Any]],
            let recommend = (dict["recommend"] ?? false) as? Bool,
            let likeCount = (dict["likeCount"] ?? 0) as? Int,
            let dislikeCount = (dict["dislikeCount"] ?? 0) as? Int,
            let uid = (dict["uid"] ?? "") as? String,
            let remarks = (dict["remarks"] ?? "") as? String,
            let created = dict["created"] as? Timestamp,
            let lastUpdated = dict["lastUpdated"] as? Timestamp else { return nil
        }
        self.attackType = attackType
        self.members.append(objectsIn: members.compactMap(TeamMember.init))
        self.recommend = recommend
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.uid = uid
        self.remarks = remarks
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }
    
    public func toAnyObject() -> [String: Any] {
        return [
            "attackType": attackType.rawValue,
            "members": Array(members).map({ $0.toAnyObject() }),
            "recommend": recommend,
            "likeCount": likeCount,
            "dislikeCount": dislikeCount,
            "uid": uid,
            "remarks": remarks,
            "created": Timestamp(date: created),
            "lastUpdated": Timestamp(date: lastUpdated)
        ]
    }
}
