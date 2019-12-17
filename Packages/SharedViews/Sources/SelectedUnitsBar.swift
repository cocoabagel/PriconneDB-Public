//
//  SelectedUnitsBar.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import SwiftUI

public struct SelectedUnitsBar: View {
    private let selectedUnits: [GameUnit]
    private let onRemove: (GameUnit) -> Void

    private let maxSlots = 5
    private let iconSize: CGFloat = 56.0
    private let spacing: CGFloat = 8.0

    private var sortedUnits: [GameUnit] {
        selectedUnits.sorted { $0.position > $1.position }
    }

    private var emptySlotCount: Int {
        max(0, maxSlots - selectedUnits.count)
    }

    public init(selectedUnits: [GameUnit], onRemove: @escaping (GameUnit) -> Void) {
        self.selectedUnits = selectedUnits
        self.onRemove = onRemove
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< emptySlotCount, id: \.self) { _ in
                emptySlot
            }

            ForEach(sortedUnits, id: \.name) { unit in
                Button {
                    onRemove(unit)
                } label: {
                    UnitIconView(unit: unit, size: iconSize)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20.0)
        .padding(.vertical, 16.0)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
        .padding(.horizontal, 16.0)
        .padding(.bottom, 8.0)
    }

    private var emptySlot: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: iconSize, height: iconSize)
            .overlay {
                Circle()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.0)
            }
    }
}
