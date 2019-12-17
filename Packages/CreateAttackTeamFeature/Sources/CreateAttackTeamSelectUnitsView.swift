//
//  CreateAttackTeamSelectUnitsView.swift
//  CreateAttackTeamFeature
//
//  Created by Kazutoshi Baba on 2025/11/28.
//

import Entity
import Resources
import SharedViews
import SwiftUI

public struct CreateAttackTeamSelectUnitsView: View {
    @State private var viewModel: CreateAttackTeamSelectUnitsViewModel
    @Environment(\.dismiss)
    private var dismiss

    private let onSave: () -> Void

    public init(defenseTeamId: String, onSave: @escaping () -> Void) {
        viewModel = CreateAttackTeamSelectUnitsViewModel(defenseTeamId: defenseTeamId)
        self.onSave = onSave
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            UnitsGridView(
                units: viewModel.outputs.allUnits,
                selectedUnits: viewModel.outputs.selectedUnits
            ) { unit in
                viewModel.inputs.toggleSelection(unit)
            }

            bottomSection
        }
        .navigationTitle("攻略チーム作成")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image.close
                        .fontWeight(.medium)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    Task {
                        let success = await viewModel.inputs.saveTeam()
                        if success {
                            onSave()
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.outputs.canProceed || viewModel.outputs.isSaving)
            }
        }
        .task {
            await viewModel.inputs.fetchUnits()
        }
        .toast(viewModel.outputs.toastMessage)
    }
}

// MARK: - Private Views
private extension CreateAttackTeamSelectUnitsView {
    var bottomSection: some View {
        VStack(spacing: 0.0) {
            SelectedUnitsBar(selectedUnits: viewModel.outputs.selectedUnits) { unit in
                viewModel.inputs.removeSelection(unit)
            }

            remarksInputSection
        }
    }

    var remarksInputSection: some View {
        HStack(alignment: .top, spacing: 12.0) {
            Image(systemName: "text.bubble")
                .foregroundStyle(.secondary)
                .padding(.top, 4.0)

            TextField(
                "コメント（任意）",
                text: Binding(
                    get: { viewModel.outputs.remarks },
                    set: { viewModel.inputs.updateRemarks($0) }
                ),
                axis: .vertical
            )
            .lineLimit(1 ... 5)
            .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 12.0)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .padding(.horizontal, 16.0)
        .padding(.vertical, 8.0)
    }
}
