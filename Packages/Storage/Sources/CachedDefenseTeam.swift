//
//  CachedDefenseTeam.swift
//  Storage
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Foundation
import SwiftData

@Model
public final class CachedDefenseTeam {
    @Attribute(.unique)
    public var id: String
    public var attackTypeRaw: String
    public var membersData: Data
    public var winsData: Data
    public var memberNames: [String]
    public var created: Date
    public var lastUpdated: Date
    public var cachedAt: Date

    public init(
        id: String,
        attackTypeRaw: String,
        membersData: Data,
        winsData: Data,
        memberNames: [String],
        created: Date,
        lastUpdated: Date,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.attackTypeRaw = attackTypeRaw
        self.membersData = membersData
        self.winsData = winsData
        self.memberNames = memberNames
        self.created = created
        self.lastUpdated = lastUpdated
        self.cachedAt = cachedAt
    }
}

// MARK: - Conversion
public extension CachedDefenseTeam {
    convenience init?(from defenseTeam: DefenseTeam) {
        let encoder = JSONEncoder()
        guard
            let membersData = try? encoder.encode(defenseTeam.members),
            let winsData = try? encoder.encode(defenseTeam.wins)
        else { return nil }

        self.init(
            id: defenseTeam.id,
            attackTypeRaw: defenseTeam.attackType.rawValue,
            membersData: membersData,
            winsData: winsData,
            memberNames: defenseTeam.members.map(\.name),
            created: defenseTeam.created,
            lastUpdated: defenseTeam.lastUpdated
        )
    }

    func toDefenseTeam() -> DefenseTeam? {
        let decoder = JSONDecoder()
        guard
            let attackType = AttackType(rawValue: attackTypeRaw),
            let members = try? decoder.decode([GameUnit].self, from: membersData),
            let wins = try? decoder.decode([AttackTeam].self, from: winsData)
        else { return nil }

        return DefenseTeam(
            id: id,
            attackType: attackType,
            members: members,
            wins: wins,
            created: created,
            lastUpdated: lastUpdated
        )
    }
}
