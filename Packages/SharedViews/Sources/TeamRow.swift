//
//  TeamRow.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import Entity
import Resources
import SwiftUI

public struct TeamRow: View {
    private let members: [GameUnit]
    private let maxMembers = 5
    private let spacing: CGFloat = 8.0

    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 64.0

    public init(members: [GameUnit]) {
        self.members = members
    }

    private var emptySlotCount: Int {
        max(0, maxMembers - members.count)
    }

    private var sortedMembers: [GameUnit] {
        members.sorted { $0.position > $1.position }
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< emptySlotCount, id: \.self) { _ in
                emptySlot
            }
            ForEach(sortedMembers, id: \.name) { member in
                UnitIconView(unit: member, size: iconSize)
            }
        }
        .padding(.vertical, 4.0)
    }

    private var emptySlot: some View {
        Image.placeholder
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
}
