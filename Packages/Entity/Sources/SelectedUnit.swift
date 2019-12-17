//
//  SelectedUnit.swift
//  Entity
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Foundation

public struct SelectedUnit: Codable, Sendable {
    public let name: String
    public let position: Int

    public init(name: String, position: Int) {
        self.name = name
        self.position = position
    }
}
