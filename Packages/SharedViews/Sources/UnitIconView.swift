//
//  UnitIconView.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/26.
//

import Entity
import Kingfisher
import KingfisherWebP
import Resources
import SwiftUI

public struct UnitIconView: View {
    private let unit: GameUnit
    private let size: CGFloat
    private let showStarRank: Bool

    public init(unit: GameUnit, size: CGFloat, showStarRank: Bool = true) {
        self.unit = unit
        self.size = size
        self.showStarRank = showStarRank
    }

    public var body: some View {
        KFImage(URL(string: unit.defaultIconURL))
            .setProcessors([WebPProcessor.default])
            .placeholder {
                Image.placeholder
                    .frame(width: size, height: size)
            }
            .fade(duration: 0.2)
            .onFailure { _ in }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .overlay(alignment: .bottom) {
                if showStarRank {
                    StarRankView(
                        starRank: unit.starRank,
                        hasUniqueEquipment: unit.uniqueEquipment
                    )
                }
            }
    }
}
