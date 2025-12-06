//
//  DefenseTeam.swift
//  Entity
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import FirebaseFirestore

public struct DefenseTeam: Sendable {
    public var id: String
    public var attackType: AttackType
    public var members: [GameUnit]
    public var wins: [AttackTeam]
    public var created: Date
    public var lastUpdated: Date

    public init(
        id: String,
        attackType: AttackType,
        members: [GameUnit],
        wins: [AttackTeam],
        created: Date,
        lastUpdated: Date
    ) {
        self.id = id
        self.attackType = attackType
        self.members = members
        self.wins = wins
        self.created = created
        self.lastUpdated = lastUpdated
    }

    public init?(document: QueryDocumentSnapshot) {
        guard
            let attackTypeString = document.data()["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = document.data()["members"] as? [[String: Any]],
            let wins = document.data()["wins"] as? [[String: Any]],
            let created = document.data()["created"] as? Timestamp,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }

        id = document.reference.documentID
        self.attackType = attackType
        self.members = members.compactMap(GameUnit.init(dict:))
        self.wins = wins.compactMap { AttackTeam(dict: $0) }
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }

    public init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let attackTypeString = data["attackType"] as? String,
            let attackType = AttackType(rawValue: attackTypeString),
            let members = data["members"] as? [[String: Any]],
            let wins = data["wins"] as? [[String: Any]],
            let created = data["created"] as? Timestamp,
            let lastUpdated = data["lastUpdated"] as? Timestamp else { return nil }

        id = document.documentID
        self.attackType = attackType
        self.members = members.compactMap(GameUnit.init(dict:))
        self.wins = wins.compactMap { AttackTeam(dict: $0) }
        self.created = created.dateValue()
        self.lastUpdated = lastUpdated.dateValue()
    }
}

// MARK: - Identifiable, Hashable
extension DefenseTeam: Identifiable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
