//
//  AttackTeam.swift
//  Entity
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import FirebaseFirestore

public struct AttackTeam: Sendable, Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var attackType: AttackType
    public var members: [GameUnit]
    public var recommend: Bool
    public var likeCount: Int
    public var dislikeCount: Int
    public var remarks: String
    public var created: Date
    public var lastUpdated: Date

    public var toAnyObject: [String: Any] {
        [
            "attackType": attackType.rawValue,
            "members": members.map(\.toAnyObject),
            "recommend": recommend,
            "likeCount": likeCount,
            "dislikeCount": dislikeCount,
            "remarks": remarks,
            "created": Timestamp(date: created),
            "lastUpdated": Timestamp(date: lastUpdated)
        ]
    }

    public init?(document: QueryDocumentSnapshot) {
        guard
            let attackTypeString = document.data()["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = document.data()["members"] as? [[String: Any]],
            let recommend = (document.data()["recommend"] ?? false) as? Bool,
            let likeCount = (document.data()["likeCount"] ?? 0) as? Int,
            let dislikeCount = (document.data()["dislikeCount"] ?? 0) as? Int,
            let remarks = (document.data()["remarks"] ?? "") as? String,
            let created = document.data()["created"] as? Timestamp,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }

        self.attackType = attackType
        self.members = members.compactMap(GameUnit.init(dict:))
        self.recommend = recommend
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.remarks = remarks
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }

    public init?(dict: [String: Any]) {
        guard
            let attackTypeString = dict["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = dict["members"] as? [[String: Any]],
            let recommend = (dict["recommend"] ?? false) as? Bool,
            let likeCount = (dict["likeCount"] ?? 0) as? Int,
            let dislikeCount = (dict["dislikeCount"] ?? 0) as? Int,
            let remarks = (dict["remarks"] ?? "") as? String,
            let created = dict["created"] as? Timestamp,
            let lastUpdated = dict["lastUpdated"] as? Timestamp
        else { return nil }
        self.attackType = attackType
        self.members = members.compactMap(GameUnit.init(dict:))
        self.recommend = recommend
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.remarks = remarks
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }

    public init(
        id: String = UUID().uuidString,
        attackType: AttackType,
        members: [GameUnit],
        recommend: Bool,
        likeCount: Int,
        dislikeCount: Int,
        remarks: String,
        created: Date,
        lastUpdated: Date
    ) {
        self.id = id
        self.attackType = attackType
        self.members = members
        self.recommend = recommend
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.remarks = remarks
        self.created = created
        self.lastUpdated = lastUpdated
    }
}
