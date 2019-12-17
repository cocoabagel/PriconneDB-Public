//
//  FilterUnitsView.swift
//  FilterUnitsFeature
//
//  Created by Kazutoshi Baba on 2025/11/29.
//

import Entity
import SharedViews
import SwiftUI

public struct FilterUnitsView: View {
    @State private var viewModel = FilterUnitsViewModel()
    @Environment(\.dismiss)
    private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 64.0), spacing: 8.0)
    ]
    private let iconSize: CGFloat = 64.0

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8.0) {
                ForEach(viewModel.outputs.allUnits, id: \.name) { unit in
                    unitCell(unit)
                }
            }
            .padding(16.0)
        }
        .navigationTitle("フィルター")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.inputs.clearAll()
                } label: {
                    Text("クリア")
                }
                .tint(.accentColor)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.inputs.save()
                    dismiss()
                } label: {
                    Text("適用")
                        .fontWeight(.semibold)
                }
                .tint(.accentColor)
            }
        }
        .task {
            await viewModel.inputs.fetchUnits()
        }
        .toast(viewModel.outputs.toastMessage)
    }
}

// MARK: - Private Views
private extension FilterUnitsView {
    func unitCell(_ unit: GameUnit) -> some View {
        let isSelected = viewModel.outputs.selectedUnitNames.contains(unit.name)

        return Button {
            viewModel.inputs.toggleSelection(unit)
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
