//
//  GameUnit+Stub.swift
//  Mocks
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import Foundation

public extension GameUnit {
    static func stub(
        name: String = "ペコリーヌ",
        position: Int = 100
    ) -> GameUnit {
        GameUnit(
            name: name,
            position: position,
            starRank: 6,
            uniqueEquipment: true,
            star3IconURL: "https://example.com/icon.png",
            star6IconURL: "https://example.com/icon6.png",
            lastUpdated: Date()
        )
    }
}
