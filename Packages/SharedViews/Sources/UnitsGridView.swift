//
//  UnitsGridView.swift
//  SharedViews
//
//  Created by Kazutoshi Baba on 2025/11/27.
//

import Entity
import SwiftUI

public struct UnitsGridView: View {
    private let units: [GameUnit]
    private let selectedUnits: [GameUnit]
    private let onTap: (GameUnit) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 64.0), spacing: 8.0)
    ]
    private let iconSize: CGFloat = 64.0

    public init(
        units: [GameUnit],
        selectedUnits: [GameUnit],
        onTap: @escaping (GameUnit) -> Void
    ) {
        self.units = units
        self.selectedUnits = selectedUnits
        self.onTap = onTap
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8.0) {
                ForEach(units, id: \.name) { unit in
                    unitCell(unit)
                }
            }
            .padding(16.0)
            .padding(.bottom, 100.0)
        }
    }

    private func unitCell(_ unit: GameUnit) -> some View {
        let isSelected = selectedUnits.contains(unit)

        return Button {
            onTap(unit)
        } label: {
            UnitIconView(unit: unit, size: iconSize)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8.0)
                            .fill(Color.white.opacity(0.4))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
