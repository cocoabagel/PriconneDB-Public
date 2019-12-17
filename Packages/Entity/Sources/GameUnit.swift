//
//  GameUnit.swift
//  Entity
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import FirebaseFirestore

public struct GameUnit: Sendable, Codable {
    public var name: String
    public var position: Int
    public var starRank: Int
    public var uniqueEquipment: Bool
    public var star3IconURL: String
    public var star6IconURL: String
    public var lastUpdated: Date

    public init(
        name: String,
        position: Int,
        starRank: Int,
        uniqueEquipment: Bool,
        star3IconURL: String,
        star6IconURL: String,
        lastUpdated: Date
    ) {
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        self.star6IconURL = star6IconURL
        self.lastUpdated = lastUpdated
    }

    public var defaultIconURL: String {
        if star6IconURL.isEmpty {
            return star3IconURL
        }

        return starRank > 5 ? star6IconURL : star3IconURL
    }

    public var toAnyObject: [String: Any] {
        [
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

    public init?(document: QueryDocumentSnapshot) {
        guard
            let name = document.data()["name"] as? String,
            let position = document.data()["position"] as? Int,
            let starRank = document.data()["starRank"] as? Int,
            let uniqueEquipment = document.data()["uniqueEquipment"] as? Bool,
            let star3IconURL = document.data()["iconURL"] as? String,
            let lastUpdated = document.data()["lastUpdated"] as? Timestamp else { return nil }

        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        star6IconURL = document.data()["star6IconURL"] as? String ?? ""
        self.lastUpdated = lastUpdated.dateValue()
    }

    public init?(dict: [String: Any]) {
        guard
            let name = dict["name"] as? String,
            let position = dict["position"] as? Int,
            let starRank = dict["starRank"] as? Int,
            let uniqueEquipment = dict["uniqueEquipment"] as? Bool,
            let star3IconURL = dict["iconURL"] as? String,
            let lastUpdated = dict["lastUpdated"] as? Timestamp else { return nil }

        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        star6IconURL = dict["star6IconURL"] as? String ?? ""
        self.lastUpdated = lastUpdated.dateValue()
    }
}

// MARK: - Equatable
extension GameUnit: Equatable {
    public static func == (lhs: GameUnit, rhs: GameUnit) -> Bool {
        lhs.position == rhs.position && lhs.name == rhs.name
    }
}
