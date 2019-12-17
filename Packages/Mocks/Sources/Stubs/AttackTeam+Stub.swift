//
//  AttackTeam+Stub.swift
//  Mocks
//
//  Created by Kazutoshi Baba on 2025/11/30.
//

import Entity
import Foundation

public extension AttackTeam {
    static func stub(
        id: String = "test-attack-id",
        attackType: AttackType = .attack,
        members: [GameUnit] = [.stub()],
        recommend: Bool = false,
        likeCount: Int = 0,
        dislikeCount: Int = 0,
        remarks: String = ""
    ) -> AttackTeam {
        AttackTeam(
            id: id,
            attackType: attackType,
            members: members,
            recommend: recommend,
            likeCount: likeCount,
            dislikeCount: dislikeCount,
            remarks: remarks,
            created: Date(),
            lastUpdated: Date()
        )
    }
}
