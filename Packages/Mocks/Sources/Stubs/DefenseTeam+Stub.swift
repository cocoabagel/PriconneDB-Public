//
//  DefenseTeam+Stub.swift
//  Mocks
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Foundation

public extension DefenseTeam {
    static func stub(
        id: String = "test-id",
        members: [GameUnit] = [.stub()],
        wins: [AttackTeam] = []
    ) -> DefenseTeam {
        DefenseTeam(
            id: id,
            attackType: .defend,
            members: members,
            wins: wins,
            created: Date(),
            lastUpdated: Date()
        )
    }
}
