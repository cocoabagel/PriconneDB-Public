//
//  StarRankView.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import Resources
import SwiftUI

public struct StarRankView: View {
    private let starRank: Int
    private let hasUniqueEquipment: Bool

    public init(starRank: Int, hasUniqueEquipment: Bool) {
        self.starRank = starRank
        self.hasUniqueEquipment = hasUniqueEquipment
    }

    public var body: some View {
        HStack(spacing: 0.0) {
            ForEach(0..<min(starRank, 6), id: \.self) { index in
                starImage(for: index)
            }
            if hasUniqueEquipment {
                Image.uniqueEquipment
            }
            Spacer()
        }
        .padding(.leading, 2.0)
    }

    private func starImage(for index: Int) -> Image {
        if starRank > 5 && index >= 5 {
            return .smallFilled6Star
        }
        return .smallFilledStar
    }
}
