//
//  Unit.swift
//  UpdateMetadata
//

import FirebaseFirestore
import Foundation

struct Unit {
    let name: String
    let position: Int
    let starRank: Int
    let uniqueEquipment: Bool
    let star3IconURL: String
    let star6IconURL: String?
    let key: String

    init(
        name: String,
        position: Int,
        starRank: Int,
        uniqueEquipment: Bool,
        star3IconURL: String,
        star6IconURL: String? = nil,
        key: String = ""
    ) {
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        self.star6IconURL = star6IconURL
        self.key = key
    }

    var toAnyObject: [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "position": position,
            "starRank": starRank,
            "uniqueEquipment": uniqueEquipment,
            "star3IconURL": star3IconURL,
            "key": key
        ]
        if let star6IconURL {
            dict["star6IconURL"] = star6IconURL
        }
        return dict
    }
}
